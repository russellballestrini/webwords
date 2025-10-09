open System
open System.Net.Http
open System.Threading.Tasks
open Microsoft.AspNetCore.Builder
open Microsoft.AspNetCore.Hosting
open Microsoft.AspNetCore.Http
open Microsoft.Extensions.Hosting
open Microsoft.Extensions.DependencyInjection

let fetchUrl (httpClient: HttpClient) (url: string) =
    async {
        try
            let! response = httpClient.GetStringAsync(url) |> Async.AwaitTask
            return Some response
        with
        | _ -> return None
    }

let handleRequest (context: HttpContext) =
    async {
        let keyword = context.Request.Query.["keyword"].ToString()
        let target = context.Request.Query.["target"].ToString()
        
        let mutable found = "false"
        
        if not (String.IsNullOrEmpty keyword) && not (String.IsNullOrEmpty target) then
            let httpClientFactory = context.RequestServices.GetRequiredService<IHttpClientFactory>()
            let httpClient = httpClientFactory.CreateClient()
            
            let! body = fetchUrl httpClient target
            match body with
            | Some content when content.Contains(keyword) ->
                found <- "true"
            | _ -> ()
            
            printfn "found=%s, keyword=%s, uri=%s" found keyword target
        
        do! context.Response.WriteAsync(found) |> Async.AwaitTask
    } |> Async.StartAsTask :> Task

type Startup() =
    member this.ConfigureServices(services: IServiceCollection) =
        services.AddHttpClient() |> ignore

    member this.Configure(app: IApplicationBuilder, env: IWebHostEnvironment) =
        if env.IsDevelopment() then
            app.UseDeveloperExceptionPage() |> ignore

        app.UseRouting() |> ignore
        
        app.UseEndpoints(fun endpoints ->
            endpoints.MapGet("/", Func<HttpContext, Task>(handleRequest)) |> ignore
        ) |> ignore
        
        printfn "listening on 0.0.0.0:31337"

[<EntryPoint>]
let main args =
    Host.CreateDefaultBuilder(args)
        .ConfigureWebHostDefaults(fun webBuilder ->
            webBuilder.UseStartup<Startup>()
                     .UseUrls("http://0.0.0.0:31337") |> ignore
        )
        .Build()
        .Run()
    
    0