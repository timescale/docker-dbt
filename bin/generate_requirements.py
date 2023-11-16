#!/usr/bin/env python3

from argparse import ArgumentParser
from pathlib import Path
import shutil
from subprocess import run, STDOUT
from tempfile import TemporaryDirectory

current_dir = Path(__file__).resolve().parent
base_requirements_dir = current_dir.parent / "requirements"

parser = ArgumentParser()
parser.add_argument("version", type=str, help="Version of dbt to generate requirements for")
parser.add_argument("adapter", type=str, help="Adapter to generate requirements for", nargs='?')
args = parser.parse_args()

version = args.version # type: str
adapter = args.adapter # type: str | None

requirements_dir = base_requirements_dir / str(args.version)

if not requirements_dir.exists():
    raise SystemExit(f"Version {args.version} not found")

with TemporaryDirectory(prefix="docker-dbt-") as tmpdir:
    tmpdir_path = Path(tmpdir)

    if adapter is None:
        print(f"Building requirements for {version}")
        shutil.copy(requirements_dir / "pyproject.toml", tmpdir_path / "pyproject.toml")
        requirements_file = "requirements.txt"
    else:
        contents = (requirements_dir / "pyproject.toml").read_text()
        if adapter not in contents:
            raise SystemExit(f"Adapter {adapter} for {version} not found")

        print(f"Building requirements for {version}/{adapter}")

        extra_requirements = []
        if adapter == "materialize":
            extra_requirements = ["postgres"]

        with (requirements_dir / "pyproject.toml").open("r") as f, (tmpdir_path / "pyproject.toml").open("w") as g:
            for line in f:
                if not line.startswith('dbt-') or any(val in line for val in ['core', 'rpc', adapter] + extra_requirements):
                    g.write(line)

        requirements_file = f"requirements-{adapter}.txt"

    shutil.copy(requirements_dir / "poetry.lock", tmpdir_path / "poetry.lock")
    print("Updating poetry.lock file")
    result = run(["poetry", "-q", "lock"], cwd=tmpdir_path)
    if result.returncode != 0:
        print(result.stdout.decode("utf-8"))
        print(result.stderr.decode("utf-8"))
        raise SystemExit("Failed to update poetry.lock file")
    print("Exporting requirements file")
    result = run(["poetry", "export", "-o", f"{requirements_dir / requirements_file}"], cwd=tmpdir_path)
    if result.returncode != 0:
        print(result.stdout.decode("utf-8"))
        print(result.stderr.decode("utf-8"))
        raise SystemExit("Failed to export requirements file")
