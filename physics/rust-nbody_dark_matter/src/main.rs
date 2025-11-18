use bevy::prelude::*;

fn main() {
    App::new()
        .add_plugins(DefaultPlugins)
        .add_systems(Update, hello)
        .run();
}

fn hello() {
    println!("Hello!")
}
