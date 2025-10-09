use std::collections::HashMap;
use warp::Filter;

#[tokio::main]
async fn main() {
    let webwords = warp::path::end()
        .and(warp::query::<HashMap<String, String>>())
        .and_then(handle_request);

    println!("listening on 0.0.0.0:31337");
    warp::serve(webwords)
        .run(([0, 0, 0, 0], 31337))
        .await;
}

async fn handle_request(params: HashMap<String, String>) -> Result<impl warp::Reply, warp::Rejection> {
    let keyword = params.get("keyword").unwrap_or(&String::new()).clone();
    let target = params.get("target").unwrap_or(&String::new()).clone();
    
    let mut found = "false";
    
    if !keyword.is_empty() && !target.is_empty() {
        match reqwest::get(&target).await {
            Ok(response) => {
                match response.text().await {
                    Ok(body) => {
                        if body.contains(&keyword) {
                            found = "true";
                        }
                        println!("found={}, keyword={}, uri={}", found, keyword, target);
                    }
                    Err(e) => {
                        println!("Error reading response: {}", e);
                    }
                }
            }
            Err(e) => {
                println!("Error making request: {}", e);
            }
        }
    }
    
    Ok(found)
}