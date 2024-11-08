import pathlib

base_dir = pathlib.Path(__file__).parent
version_file = base_dir.parent / "libraries_version.txt"
version_folder = base_dir.parent.joinpath("versions")
version_folder.mkdir(exist_ok=True, parents=True)

for l in version_file.open("r", encoding='utf-8').readlines():
    if l.startswith("#") or l.strip() == "":
        continue
    # 行内注释
    l = l[: l.find('#')].strip()

    lib, version = l.strip().split("=")
    lib = lib.strip()
    version = version.strip()
    with version_folder.joinpath(f"{lib}").open("w", encoding='utf-8') as f:
        f.write(f'{version}')
