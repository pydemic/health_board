library("read.dbc")
library("tools")

for (filename in dir(path="/app/input")) {
    write.csv(
        read.dbc(paste("/app/input/", filename, sep="")),
        file=paste("/app/output/", file_path_sans_ext(filename), ".csv", sep="")
    )
}
