import vweb
import net.http

struct App {
	vweb.Context
}

fn main() {
	println('listening on 0.0.0.0:31337')
	vweb.run(&App{}, 31337)
}

@['/'; get]
pub fn (mut app App) index() vweb.Result {
	keyword := app.query['keyword'] or { '' }
	target := app.query['target'] or { '' }
	mut found := 'false'
	
	if keyword != '' && target != '' {
		resp := http.get(target) or {
			println('Error fetching ${target}: ${err}')
			return app.text(found)
		}
		
		if resp.body.contains(keyword) {
			found = 'true'
		}
		
		println('found=${found}, keyword=${keyword}, uri=${target}')
	}
	
	return app.text(found)
}