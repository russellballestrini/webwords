Imports System
Imports System.Net.Http
Imports System.Threading.Tasks
Imports Microsoft.AspNetCore.Builder
Imports Microsoft.AspNetCore.Hosting
Imports Microsoft.AspNetCore.Http
Imports Microsoft.Extensions.Hosting
Imports Microsoft.Extensions.DependencyInjection

Namespace WebWords
    Public Class Program
        Public Shared Sub Main(args As String())
            CreateHostBuilder(args).Build().Run()
        End Sub

        Public Shared Function CreateHostBuilder(args As String()) As IHostBuilder
            Return Host.CreateDefaultBuilder(args) _
                .ConfigureWebHostDefaults(Sub(webBuilder)
                    webBuilder.UseStartup(Of Startup)()
                    webBuilder.UseUrls("http://0.0.0.0:31337")
                End Sub)
        End Function
    End Class

    Public Class Startup
        Public Sub ConfigureServices(services As IServiceCollection)
            services.AddHttpClient()
        End Sub

        Public Sub Configure(app As IApplicationBuilder, env As IWebHostEnvironment)
            If env.IsDevelopment() Then
                app.UseDeveloperExceptionPage()
            End If

            app.UseRouting()

            app.UseEndpoints(Sub(endpoints)
                endpoints.MapGet("/", AddressOf HandleRequest)
            End Sub)

            Console.WriteLine("listening on 0.0.0.0:31337")
        End Sub

        Private Async Function HandleRequest(context As HttpContext) As Task
            Dim keyword As String = context.Request.Query("keyword").ToString()
            Dim target As String = context.Request.Query("target").ToString()

            Dim httpClientFactory = context.RequestServices.GetRequiredService(Of IHttpClientFactory)()
            Dim httpClient = httpClientFactory.CreateClient()

            Dim found As String = "false"

            If Not String.IsNullOrEmpty(keyword) AndAlso Not String.IsNullOrEmpty(target) Then
                Try
                    Dim response As String = Await httpClient.GetStringAsync(target)
                    If response.Contains(keyword) Then
                        found = "true"
                    End If

                    Console.WriteLine($"found={found}, keyword={keyword}, uri={target}")
                Catch ex As Exception
                    Console.WriteLine($"Error: {ex.Message}")
                End Try
            End If

            Await context.Response.WriteAsync(found)
        End Function
    End Class
End Namespace