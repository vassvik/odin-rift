import (
	"fmt.odin";
	"strings.odin";
	"math.odin";
	"external/odin-glfw/glfw.odin";
	"external/odin-gl/gl.odin";
	"external/odin-fbx/fbx.odin";
)

Vec3 :: struct #ordered {
	x, y, z: f32;
};

Vertex :: struct #ordered {
	position, normal: Vec3;
};

Model :: struct {
	vertices: []Vertex;
	
	num_vertices: int;
	num_triangles: int;

	bbox: [6]f32 = [6]f32{1.0e9, -1.0e9, 1.0e9, -1.0e9, 1.09e9, -1.0e9};

	vao: u32;
	vbo: u32;
};

model_init_and_upload :: proc(using model: ^Model) {
	gl.CreateBuffers(1, &vbo);
	gl.NamedBufferData(vbo, size_of(Vertex)*num_vertices, &vertices[0], gl.STATIC_DRAW);
	
	gl.CreateVertexArrays(1, &vao);
	gl.VertexArrayVertexBuffer(vao, 0, vbo, 0, size_of(Vertex));

	gl.EnableVertexArrayAttrib(vao, 0);
	gl.EnableVertexArrayAttrib(vao, 1);
	
	gl.VertexArrayAttribFormat(vao, 0, 3, gl.FLOAT, gl.FALSE, 0);
	gl.VertexArrayAttribFormat(vao, 1, 3, gl.FLOAT, gl.FALSE, 12);

	gl.VertexArrayAttribBinding(vao, 0, 0);
	gl.VertexArrayAttribBinding(vao, 1, 0);
}



main :: proc() {
	resx, resy := 1600.0, 900.0;
	window, success := init_glfw(i32(resx), i32(resy), "Odin Font Rendering");
	if !success {
		glfw.Terminate();
		return;
	}
	defer glfw.Terminate();

	set_proc_address :: proc(p: rawptr, name: string) { 
		(cast(^rawptr)p)^ = rawptr(glfw.GetProcAddress(&name[0]));
	}
	gl.load_up_to(4, 5, set_proc_address);

	gl.ClearColor(0.2, 0.3, 0.4, 1.0);

	

	program, shader_success := gl.load_shaders("shaders/shader_solids.vs", "shaders/shader_solids.fs");
	defer gl.DeleteProgram(program);
	
	load_part :: proc(part: ^fbx.Geometry) -> Model {
		using model: Model;
		vertices = make([]Vertex, len(part.indices));

		for index, j in part.indices {
			i := int(index < 0 ? -1*index - 1 : index);
			x,  y,  z  := part.vertices[3*i+0], part.vertices[3*i+1], part.vertices[3*i+2];
			nx, ny, nz := part.normals[3*j+0],  part.normals[3*j+1],  part.normals[3*j+2];

			bbox[0] = min(bbox[0], f32(x));
			bbox[1] = max(bbox[1], f32(x));
			bbox[2] = min(bbox[2], f32(y));
			bbox[3] = max(bbox[3], f32(y));
			bbox[4] = min(bbox[4], f32(z));
			bbox[5] = max(bbox[5], f32(z));

			vertices[j] = Vertex{Vec3{f32(x),  f32(y),  f32(z)},
								 Vec3{f32(nx), f32(ny), f32(nz)}};
		}

		fmt.println(bbox);


		num_vertices = len(vertices);
		num_triangles = num_vertices/3;

		model_init_and_upload(&model);
		
		return model;
	}

	fbx_right := fbx.load_fbx("models/rightController.FBX");
	model := fbx.create_model_from_fbx(&fbx_right);

	models := make([]Model, len(model.parts));

	for _, i in model.parts {
		models[i] = load_part(&model.parts[i]);
	}

	p := math.Vec3{0.0, 0.0, 5.0};

	// @NOTE: The camera directions use spherical coordianates, 
	//        in particular, physics conventions are used: 
	//        theta is up-down, phi is left-right
	theta, phi := f32(math.π), f32(math.π/2.0);

	sinp, cosp := math.sin(phi),   math.cos(phi);
	sint, cost := math.sin(theta), math.cos(theta);

	f := math.Vec3{cosp*sint, sinp*sint, cost};                   // forward vector, normalized, spherical coordinates
	r := math.Vec3{sinp, -cosp, 0.0};                             // right vector, relative to forward
	u := math.Vec3{-cosp*cost, -sinp*cost, sint};                 // "up" vector, u = r x f

	// for mouse movement
	mx_prev, my_prev: f64;
	glfw.GetCursorPos(window, &mx_prev, &my_prev);

	// for timings
	t_prev := glfw.GetTime();
	frame := 0;


	gl.Enable(gl.DEPTH_TEST);

	for glfw.WindowShouldClose(window) == glfw.FALSE {
		glfw.calculate_frame_timings(window);
		
		glfw.PollEvents();


		// time delta for fps-independent movement speed
		t_now := glfw.GetTime();
		dt := f32(t_now - t_prev);
		t_prev = t_now;

		// get current mouse position
		mx, my: f64;
		glfw.GetCursorPos(window, &mx, &my);

		// update camera direction
		if glfw.GetMouseButton(window, glfw.MOUSE_BUTTON_1) == glfw.PRESS {
			radiansPerPixel := f32(0.1 * math.π / 180.0);
			phi = phi - f32(mx - mx_prev) * radiansPerPixel;
			theta = clamp(theta + f32(my - my_prev) * radiansPerPixel, 1.0*math.π/180.0, 179.0*math.π/180.0);
		}

		mx_prev = mx;
		my_prev = my;

		// calculate updated local camera coordinate system
		sinp, cosp = math.sin(phi),   math.cos(phi);
		sint, cost = math.sin(theta), math.cos(theta);

		f = math.Vec3{cosp*sint, sinp*sint, cost};                   // forward vector, normalized, spherical coordinates
		r = math.Vec3{sinp, -cosp, 0.0};                             // right vector, relative to forward
		u = math.Vec3{-cosp*cost, -sinp*cost, sint};                 // "up" vector, u = r x f

		if glfw.GetKey(window, glfw.KEY_LEFT_CONTROL) == glfw.PRESS {
			dt *= 10.0;
		}

		// update camera position:
		// W: forward, S: back, A: left, D: right, E: up, Q: down
		p += f*f32(glfw.GetKey(window, glfw.KEY_W) - glfw.GetKey(window, glfw.KEY_S))*dt;
		p += r*f32(glfw.GetKey(window, glfw.KEY_D) - glfw.GetKey(window, glfw.KEY_A))*dt;
		p += u*f32(glfw.GetKey(window, glfw.KEY_E) - glfw.GetKey(window, glfw.KEY_Q))*dt;

		// Main drawing part
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

		gl.UseProgram(program);
		gl.Uniform1f(get_uniform_location(program, "time\x00"), f32(glfw.GetTime()));
		gl.Uniform3f(get_uniform_location(program, "camera_pos\x00"), f32(p.x), f32(p.y), f32(p.z));

		V := view(r, u, f, p);
		P := math.perspective(3.1415926*45.0/180.0, 1280/720.0, 0.001, 100.0);

        gl.Uniform3f(get_uniform_location(program, "albedo"), 0.0, 0.0, 0.0);
        gl.Uniform1f(get_uniform_location(program, "metallic"), 0.1);
        gl.Uniform1f(get_uniform_location(program, "roughness"), 0.5);
        gl.Uniform1f(get_uniform_location(program, "ao"), 1.0);
        
        d :f32 = 10.0;
        light_positions := [...]f32 {
            -d,  d, d,
             d,  d, d,
            -d, -d, d,
             d, -d, d,
        };

        l :f32= 300.0;
        light_colors := [...]f32 {
            l, l, 1.0*l,
            l, l, 1.0*l,
            l, l, 1.0*l,
            l, l, 1.0*l
        };
        gl.Uniform3fv(get_uniform_location(program, "lightPositions\x00"), 4, &light_positions[0]);
        gl.Uniform3fv(get_uniform_location(program, "lightColors\x00"), 4, &light_colors[0]);

        gl.Uniform3f(get_uniform_location(program, "camPos"), p.x, p.y, p.z);

		for model, i in models {
			M := math.mat4_translate(math.Vec3{0.0, 0.0, 0.0});
			MV := math.mul(V, M);
			MVP := math.mul(P, MV);


			gl.Uniform3f(get_uniform_location(program, "sphere_pos\x00"), 0.0, 0.0, 0.0);
			gl.UniformMatrix4fv(get_uniform_location(program, "MVP\x00"), 1, gl.FALSE, &MVP[0][0]);
			gl.Uniform3f(get_uniform_location(program, "scale\x00"), 1.0, 1.0, 1.0);


			gl.BindVertexArray(model.vao);
			gl.DrawArrays(gl.TRIANGLES, 0, i32(model.num_vertices));
			//break;
		}

		
		glfw.SwapBuffers(window);
	}
}

// Right handed view matrix, defined from camera position and a local 
// camera coordinate system, namely right (X), up (Y) and forward (-Z).
// Hopefully this one gets added to core/math.odin eventually.
view :: proc(r, u, f, p: math.Vec3) -> math.Mat4 { 
	return math.Mat4 { // HERE
		{+r.x, +u.x, -f.x, 0.0},
		{+r.y, +u.y, -f.y, 0.0},
		{+r.z, +u.z, -f.z, 0.0},
		{-math.dot(r,p), -math.dot(u,p), math.dot(f,p), 1.0},
	};
}

// wrapper to use GetUniformLocation with an Odin string
// @NOTE: str has to be zero-terminated, so add a \x00 at the end
get_uniform_location :: proc(program: u32, str: string) -> i32 {
	return gl.GetUniformLocation(program, &str[0]);;
}

error_callback :: proc(error: i32, desc: ^u8) #cc_c {
	fmt.printf("Error code %d:\n    %s\n", error, strings.to_odin_string(desc));
}

init_glfw :: proc(resx, resy: i32, title: string) -> (^glfw.window, bool) {
	glfw.SetErrorCallback(error_callback);

	if glfw.Init() == 0 do return nil, false;

	glfw.WindowHint(glfw.SAMPLES, 4);
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4);
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 5);
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE);

	window := glfw.CreateWindow(resx, resy, title, nil, nil);
	if window == nil do return nil, false;
	
	glfw.MakeContextCurrent(window);
	glfw.SwapInterval(1);

	return window, true;
}

// Minimal Standard LCG
seed : u32 = 12345;
rng :: proc() -> f64 {
	seed *= 16807;
	return f64(seed) / f64(0x100000000);
}
