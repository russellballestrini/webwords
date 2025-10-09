FROM julia:1.9

WORKDIR /app
COPY Project.toml .
RUN julia -e 'using Pkg; Pkg.activate("."); Pkg.instantiate(); Pkg.precompile()'

COPY src ./src

EXPOSE 31337

CMD ["julia", "--project=.", "src/webwords.jl"]