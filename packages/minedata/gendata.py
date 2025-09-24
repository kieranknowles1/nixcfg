#!/usr/bin/env python3

WOOD_TYPES = [
    "oak",
    "spruce",
    "birch",
    "jungle",
    "acacia",
    "dark_oak",
    "mangrove",
    "cherry",
    "pale_oak",
]

WOOD_RECIPES = ["saw_fence", "saw_planks", "saw_slab", "saw_stairs"]

def gen_wood_recipes():
    for recipe in WOOD_RECIPES:
        for wood in WOOD_TYPES:
            apply_template(recipe, wood, {
                "fulllog": f"{wood}_log",
                "log": wood,
            })
        # These use "stem" instead of "log", so need to be handled separately
        apply_template(recipe, "crimson", {
            "fulllog": "crimson_stem",
            "log": "crimson",
        })
        apply_template(recipe, "warped", {
            "fulllog": "warped_stem",
            "log": "warped",
        })


def apply_template(template: str, name: str, replacements: dict[str, str]):
    with open(f"templates/{template}.json", "r") as file:
        template_content = file.read()
    for replacement in replacements.items():
        template_content = template_content.replace(
            f"${replacement[0]}$", replacement[1]
        )

    if "$" in template_content:
        raise ValueError(f"Template {template} contains unresolved variables")

    with open(f"output/{template}_{name}.json", "w") as file:
        file.write(template_content)


def main():
    gen_wood_recipes()


if __name__ == "__main__":
    main()
