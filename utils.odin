import "core:os.odin";
import "core:fmt.odin";


Vec2 :: struct {
	x, y: f32,
}

Vec3 :: struct {
	x, y, z: f32,
}

Model :: struct {
	positions: []Vec3,
	normals: []Vec3,
	uvs: []Vec2,
	indices: []i32,

	vao: u32,
	vbos: [3]u32,
	ebo: u32,
}

strip_leading_whitespace :: proc(data: string) -> (rest: string) {
	for b, i in data {
		switch b {
		case: return rest = data[i..];
		case ' ', '\t', '\n', '\v', '\f', '\r':
		}
	}
	return rest = "";
}

get_next_line :: proc(data: string) -> (line, rest: string) {
	for b, i in data {
		switch b {
		case '\n','\r':
			return line = data[..i], rest = strip_leading_whitespace(data[i..]);
		}
	}

	return line = data, rest = "";
}

split_line_into_words :: proc(data: string, delims: []rune = nil) -> []string {
	words: [dynamic]string;

	outer:
	for data != "" {
		data = strip_leading_whitespace(data);
		if data == "" do break outer;

		inner:
		for c, i in data {
			for d in delims {
				if c == d {
					append(&words, data[0..i]);
					data = data[i+1..];
					continue outer;
				}
			}
			// default, if delims == nil
			switch c {
			case ' ', '\t', '\n':
				append(&words, data[0..i]);
				data = data[i..];
				continue outer;
			}
		}
		append(&words, data);
		break outer;
	}

	return words[..];
}

read_obj :: proc(filename: string) -> (Model, bool) {
	data, status := os.read_entire_file(filename);
	if !status do return Model{}, false;
	defer free(data);

	positions: [dynamic]Vec3;
	normals: [dynamic]Vec3;
	uvs: [dynamic]Vec2;
	indices: [dynamic]i32;

	line, rest := "", cast(string)data;
	for rest != "" {
		line, rest = get_next_line(rest);
		if line == "" do continue;
		if !(line[0] == 'v' || line[0] == 'f') do continue;

		words := split_line_into_words(line, []rune{' ', '/'});
		defer free(words);
		
		switch words[0] {
		case "v":
			assert(len(words) == 4, "Error, expected 3 elements");
			append(&positions, Vec3{f32_from_string(words[1]), f32_from_string(words[2]), f32_from_string(words[3])});
		case "vn":
			assert(len(words) == 4, "Error, expected 3 elements");
			append(&normals, Vec3{f32_from_string(words[1]), f32_from_string(words[2]), f32_from_string(words[3])});
		case "vt":
			assert(len(words) == 3, "Error, expected 2 elements");
			append(&uvs, Vec2{f32_from_string(words[1]), f32_from_string(words[2])});
		case "f":
			// @WARNING: Only works for .obj files that looks like A/A/A B/B/B C/C/C, 
			// i.e. three vertices per face, and the same index for position, normal and uv.
			assert(len(words) == 10, "Error, expected 3 triplets");
			append(&indices, i32_from_string(words[1])-1, i32_from_string(words[4])-1, i32_from_string(words[7])-1);			
		}
	}

	fmt.println(len(positions), len(normals), len(uvs), len(indices));

	return Model{positions[..], normals[..], uvs[..], indices[..], 0, [...]u32{0, 0, 0}, 0}, true;
}

i32_from_string :: proc(str: string) -> i32 {
	return cast(i32)int_from_string(str);
}

int_from_string :: proc(str: string) -> int {
    sign := (str[0] == '-') ? -1 : 1;
    start := (str[0] == '+' || str[0] == '-') ? 1 : 0;

    val := cast(int)(str[start] - '0');
    
    for c in str[start+1..] {
        val *= 10;
        val += cast(int)(c - '0');
    }
    return sign*val;
}

f32_from_string :: proc(str: string) -> f32 {
	return cast(f32)f64_from_string(str);
}

f64_from_string :: proc(str: string) -> f64 {
    digit_value :: proc(r: u8) -> i64 {
        return i64(r - '0');
    }

    i : int = 0;
    num_bytes := len(str);

    sign := 1.0;
    if str[i] == '-' {
        sign = -1.0;
        i += 1;
    } else if (str[i] == '+') {
        i += 1;
    }

    value := 0.0;
    for i < num_bytes {

        v := digit_value(str[i]);
        if v >= 10 do break;
        value *= 10.0;
        value += f64(v);

        i += 1;
    }

    if i < num_bytes && str[i] == '.' {
        pow10 := 10.0;
        i += 1;
        for i < num_bytes {
            v := digit_value(str[i]);
            if v >= 10 do break;
            value += f64(v)/pow10;
            pow10 *= 10.0;

            i += 1;
        }
    }

    frac := false;
    scale := 1.0;
    if i < num_bytes && ((str[i] == 'e') || (str[i] == 'E')) {
        i += 1;

        if (str[i] == '-') {
            frac = true;
            i += 1;
        } else if (str[i] == '+') {
            i += 1;
        }

        exp : u32 = 0;
        for i < num_bytes {
            d := u32(digit_value(str[i]));
            if d >= 10 do break;
            exp = exp * 10 + d;
            i += 1;
        }
        if exp > 308 do exp = 308;
        

        for (exp >= 50) { scale *= 1e50; exp -= 50; }
        for (exp >=  8) { scale *= 1e8;  exp -=  8; }
        for (exp >   0) { scale *= 10.0; exp -=  1; }
    }

    return sign * (frac ? (value / scale) : (value * scale));
}
