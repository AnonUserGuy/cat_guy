import sys
sys.dont_write_bytecode = True
from PIL import Image

colors_in: list[list[str|tuple[int, int, int]]] = [
    ["#FFF7C6"],
    ["#FFEF8C", "#E3C6C5"],
    ["#CEAD6B", "#CF9C9B"],
    ["#75492C", "#B97371"],
    ["#BDFFDE"],
    ["#5AFFA5"],
]

colors_out: dict[str, list[str|tuple[int, int, int]]] = {
    "black": [
        "#383838",
        "#2E2E2E",
        "#232323",
        "#181818",
        "#B7B7B7"
    ],
    "blue": [
        "#748AA8",
        "#566C8A",
        "#405066",
        "#2C3747"
    ],
    "green": [
        "#E9FFE0",
        "#CBEFBF",
        "#9FCF8F",
        "#7BA467",
        "#E0F3CE"
    ],
    "grey": [
        "#C9C9C9",
        "#A7A7A7",
        "#787878",
        "#545454",
        "#B7B7B7"
    ],
    "red": [
        "#A64747",
        "#992424",
        "#792020",
        "#571717",
        "#FFD4D4",
        "#FF5A5A"
    ],
#    "white": [
#        "#FFFFFF",
#        "#FFFFFF",
#        "#E2E2E2",
#        "#C2C2C2",
#        "#E2E2E2"
#    ]
}

def main():
    prepare_colors()
    for i in range(1, len(sys.argv)):
        colorize(sys.argv[i])

def colorize(path: str):
    with Image.open(path) as img:
        img: Image.Image
        data = img.load()
        if not data:
            return
        color_map: list[list[tuple[int, int]]] = [[] for _ in range(len(colors_in))]
        for y in range(img.height):
            for x in range(img.width):
                r, g, b, _, = data[x, y] # type: ignore
                #print(f"({x}, {y}): {r} {g} {b}")
                i = find_color(r, g, b)
                if i != None:
                    #print(f"found match {i}: {x}, {y}")
                    color_map[i].append((x, y))
        
        for name in colors_out:
            img_new = img.copy()
            data_new = img_new.load()
            if not data_new:
                return
            for i in range(len(colors_out[name])):
                r0, g0, b0 = colors_out[name][i]
                for j in range(len(color_map[i])):
                    x0, y0 = color_map[i][j]
                    _, _, _, a0 = data_new[x0, y0] # type: ignore
                    data_new[x0, y0] = (r0, g0, b0, a0) # type: ignore
            img_new.save(f"{path[:-4]}_{name}.png")
                        
def find_color(r: int, g: int, b: int):
    for i in range(len(colors_in)):
        colors = colors_in[i]
        for color in colors:
            r0, g0, b0 = color
            #print(f"{i} - {r0} {g0} {b0}?")
            if r == r0 and g == g0 and b == b0:
                return i
    return None

def prepare_colors():
    for i in range(len(colors_in)):
        for j in range(len(colors_in[i])):
            color_str = colors_in[i][j]
            if isinstance(color_str, str):
                colors_in[i][j] = color_str_to_color(color_str)

    for name in colors_out:
        for j0 in range(len(colors_out[name])):
            color_str = colors_out[name][j0]
            if isinstance(color_str, str):
                colors_out[name][j0] = color_str_to_color(color_str)


def color_str_to_color(color_str: str):
    r = int(color_str[1:3], 16)
    g = int(color_str[3:5], 16)
    b = int(color_str[5:7], 16)
    return (r, g, b)


if __name__ == "__main__":
    main()