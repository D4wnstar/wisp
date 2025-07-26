using MLDatasets, Plots, DataFrames

# Dataset plots
function make_plots(type::Symbol)
    iris = Iris()

    # Plotting data
    setosa = iris.dataframe[iris.dataframe.class.=="Iris-setosa", :]
    versi = iris.dataframe[iris.dataframe.class.=="Iris-versicolor", :]
    virgi = iris.dataframe[iris.dataframe.class.=="Iris-virginica", :]

    if type == :petals
        p = scatter(
            [
                setosa.petallength,
                versi.petallength,
                virgi.petallength,
            ],
            [
                setosa.petalwidth,
                versi.petalwidth,
                virgi.petalwidth,
            ],
            label=["Setosa" "Versicolor" "Virginica"],
            xlims=(0.9, 7.1),
            ylims=(0, 2.6),
            xlabel="Petal length [cm]",
            ylabel="Petal width [cm]",
            marker=[:o :diamond :hexagon],
        )
        return p
    end

    if type == :sepals
        p = scatter(
            [
                setosa.sepallength,
                versi.sepallength,
                virgi.sepallength,
            ],
            [
                setosa.sepalwidth,
                versi.sepalwidth,
                virgi.sepalwidth,
            ],
            label=["Setosa" "Versicolor" "Virginica"],
            xlims=(4.0, 8.0),
            ylims=(1.9, 4.6),
            xlabel="Sepal length [cm]",
            ylabel="Sepal width [cm]",
            marker=[:o :diamond :hexagon],
        )
        return p
    end
end

p_petals = make_plots(:petals)
savefig(p_petals, "plots/petal_plot.png")

p_sepals = make_plots(:sepals)
savefig(p_sepals, "plots/sepal_plot.png")
