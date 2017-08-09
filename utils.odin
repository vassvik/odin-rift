import (
	"os.odin";
	"fmt.odin";
)

Vec2 :: struct {
	x, y: f32;
}

Vec3 :: struct {
	x, y, z: f32;
}

Model :: struct {
	positions: []Vec3;
	normals: []Vec3;
	uvs: []Vec2;
}

strip_leading_whitespace :: proc(data: string) -> (rest: string) {
	for b, i in data {
		match b {
		case: return rest = data[i..];
		case ' ', '\t', '\n', '\v', '\f', '\r':
		}
	}
	return rest = "";
}

get_next_line :: proc(data: string) -> (line, rest: string) {
	for b, i in data {
		match b {
		case '\n','\r':
			return line = data[..i], rest = strip_leading_whitespace(data[i..]);
		}
	}

	return line = data, rest = "";
}

split_line_into_words :: proc(data: string) -> []string {
	words: [dynamic]string;

	outer:
	for data != "" {
		data = strip_leading_whitespace(data);
		if data == "" do break outer;

		inner:
		for c, i in data {
			match c {
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

	line, rest := "", cast(string)data;
	for rest != "" {
		line, rest = get_next_line(rest);
		if line == "" do continue;
		if !(line[0] == 'v' || line[0] == 'f') do continue;

		fmt.println("_", line, "_");
		words := split_line_into_words(line);
		
		match words[0] {
		case "v":

		case "vn":

		case "vt":

		case "f":
			
		}
	}

	return Model{}, true;
}
