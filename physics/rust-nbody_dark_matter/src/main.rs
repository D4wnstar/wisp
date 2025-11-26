#![allow(non_snake_case)] // For mathematical variables

use std::sync::Mutex;

use bevy::{dev_tools::fps_overlay::FpsOverlayPlugin, math::NormedVectorSpace, prelude::*};
use rand::Rng;

fn main() {
    App::new()
        .add_plugins(DefaultPlugins)
        .add_plugins(FpsOverlayPlugin::default())
        .insert_resource(ScaleFactor(START_SCALE))
        .insert_resource(HubbleParameter(
            HUBBLE_CONSTANT * START_HUBBLE_PARAM_SQ.sqrt(),
        ))
        .add_systems(Startup, setup)
        .add_systems(FixedUpdate, integrate)
        .add_systems(Update, update_ui)
        .run();
}

/// The number of bodies in the simulation.
const N: usize = 2000;

const TOTAL_MASS: f32 = 10e14; // Solar masses

const SIMULATION_SPEED: f32 = 60.0; // Myr/s (1 Myr/step at 60 FPS)

/// The gravitational softening length.
const GRAV_SOFT: f32 = 2.0; // Mpc
/// The square of the gravitational softening length.
const GRAV_SOFT_SQ: f32 = GRAV_SOFT * GRAV_SOFT;

/// Newton's gravitational constant.
const G: f32 = 4.50e-21; // Mpc^3 / (solar mass * Myr^2)

// Cosmological parameters
const OMEGA_MATTER: f32 = 0.315;
const OMEGA_LAMBDA: f32 = 0.682;
const OMEGA_K: f32 = 1.0 - OMEGA_MATTER - OMEGA_LAMBDA;
const HUBBLE_CONSTANT: f32 = 6.893e-5; // Myr^-1

const START_REDSHIFT: f32 = 100.0; // ~16.6 Myr cosmic time in flat spacetime
const START_TIME: f32 = 16.6; // Myr at redshift 100
const START_SCALE: f32 = 1.0 / (1.0 + START_REDSHIFT);
const START_HUBBLE_PARAM_SQ: f32 = OMEGA_MATTER / (START_SCALE * START_SCALE * START_SCALE)
    + OMEGA_K / (START_SCALE * START_SCALE)
    + OMEGA_LAMBDA;

#[derive(Resource)]
struct ScaleFactor(f32);

#[derive(Resource)]
struct HubbleParameter(f32);

#[derive(Component)]
#[require(Transform, Visibility, Mesh3d, MeshMaterial3d<StandardMaterial>)]
struct Body {
    mass: f32,
    velocity: Vec3,
    /// Last step's f(x_{n+1}). Should be reused as next step's f(x_n).
    /// None during the first step.
    accel: Option<Vec3>,
}

impl Default for Body {
    fn default() -> Self {
        Self {
            mass: TOTAL_MASS / N as f32,
            velocity: Vec3::ZERO,
            accel: None,
        }
    }
}

#[derive(Component)]
struct UiText;

fn setup(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>,
) {
    let radius = 0.1; // Mpc (just for visualization)

    let mesh = meshes.add(Sphere::new(radius).mesh().ico(3).unwrap());
    let mat = materials.add(Color::srgba(0.5, 0.0, 0.5, 1.0));

    // Spawn particles
    let mut rng = rand::rng();
    for _ in 0..N {
        // Spawn particles randomly in a 15 Mpc sphere centered in the origin
        // TODO: Add proper cosmological starting conditions.
        let pos = Vec3::new(
            rng.random_range(-1.0..1.0),
            rng.random_range(-1.0..1.0),
            rng.random_range(-1.0..1.0),
        ) * 15.;

        commands.spawn((
            Body::default(),
            Transform::from_translation(pos),
            Mesh3d(mesh.clone()),
            MeshMaterial3d(mat.clone()),
        ));
    }

    // Spawn camera
    commands.spawn((
        Camera3d::default(),
        Transform::from_xyz(0.0, 0.0, -50.0).looking_at(Vec3::ZERO, Vec3::Y),
    ));

    // Set up UI
    commands.spawn((
        Text::new(
            "Cosmic time: t = 16.6 Myr\nScale factor: a = 0.099\nHubble parameter: H = 1 Myr^-1",
        ),
        Node {
            position_type: PositionType::Absolute,
            bottom: px(5),
            left: px(5),
            ..default()
        },
        UiText,
    ));
}

fn integrate(
    time: Res<Time>,
    mut a: ResMut<ScaleFactor>,
    mut H: ResMut<HubbleParameter>,
    mut particles: Query<(&mut Body, &mut Transform)>,
) {
    let dt = time.delta_secs() * SIMULATION_SPEED;

    // Update cosmological parameters
    a.0 += H.0 * a.0 * dt; // Explicit Euler for ȧ = H(t)a
    let a_sq = a.0.powi(2);
    let a_cb = a.0.powi(3);
    H.0 = HUBBLE_CONSTANT * (OMEGA_MATTER / a_cb + OMEGA_K / a_sq + OMEGA_LAMBDA).sqrt();

    // Integrate motion
    // Results are kept behind a mutex to allow parallel iteration
    let new_coords = Mutex::new(Vec::new());

    particles.par_iter().for_each(|(part_i, tr_i)| {
        let x_i = tr_i.translation;

        // Equation of motion for the ODE ẍ = f(x)
        let f = |x_i: Vec3| {
            let mut potential_grad = Vec3::ZERO;

            for (part_j, tr_j) in &particles {
                let x_j = tr_j.translation;
                let r = x_i - x_j;
                potential_grad += G * part_j.mass * r / (r.norm_squared() + GRAV_SOFT_SQ).powf(1.5);
            }

            // vvv  Gravitation      vvv  Hubble drag
            -potential_grad / a_cb - 2.0 * H.0 * part_i.velocity
        };

        // Use leapfrog integration
        // If there is a stored acceleration f(x) from last step, reuse it, else calculate it
        let new_vel_mid = match part_i.accel {
            Some(accel) => part_i.velocity + accel * dt / 2.0,
            None => part_i.velocity + f(x_i) * dt / 2.0,
        };
        let new_pos = x_i + new_vel_mid * dt;
        let accel = f(new_pos);
        let new_vel = new_vel_mid + accel * dt / 2.0;

        let mut lock = new_coords.lock().unwrap();
        lock.push((new_pos, new_vel, accel));
    });

    // Apply new values
    for ((mut part, mut transform), (new_pos, new_vel, new_accel)) in
        particles.iter_mut().zip(new_coords.into_inner().unwrap())
    {
        transform.translation = new_pos;
        part.velocity = new_vel;
        part.accel = Some(new_accel);
    }
}

fn update_ui(
    time: Res<Time>,
    scale: Res<ScaleFactor>,
    hubble: Res<HubbleParameter>,
    mut query: Query<&mut Text, With<UiText>>,
) {
    // Update cosmic time, scale factor and Hubble parameter
    let t = START_TIME + time.elapsed_secs() * SIMULATION_SPEED;
    let a = scale.0;
    let H = hubble.0;
    let z = 1.0 / a - 1.0;

    let mut text = query.iter_mut().next().unwrap();
    text.0 = format!(
        "Cosmic time: t = {t:.0} Myr\nRedshift: z = {z:.2}\nScale factor: a = {a:.3}\nHubble parameter: H = {H:.5} Myr^-1"
    );
}
