#!/usr/bin/env python3
"""
Combined setup script for Parflow: download, build, and test.
"""

import argparse
import subprocess
import sys
import os
from pathlib import Path


def run_command(cmd, description):
    """Run a shell command and handle errors."""
    print(f"\n{'='*60}")
    print(f"Running: {description}")
    print(f"{'='*60}")
    try:
        subprocess.run(cmd, shell=True, check=True)
        print(f"✓ {description} completed successfully")
    except subprocess.CalledProcessError as e:
        print(f"✗ {description} failed with exit code {e.returncode}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"✗ Error running {description}: {e}", file=sys.stderr)
        sys.exit(1)


def download(src_dir="parflow"):
    """Download the Parflow repository."""
    src_dir = Path(src_dir).absolute()
    cmd = f"git clone -b master --single-branch https://github.com/parflow/parflow.git {src_dir}"
    run_command(cmd, "Download Parflow")


def build(
    clean=False, src_dir="parflow", bld_dir="build", ins_dir="install", settings=[]
):
    """Build and install Parflow."""
    src_dir = Path(src_dir).absolute()
    bld_dir = Path(bld_dir).absolute()
    ins_dir = Path(ins_dir).absolute()
    if clean and Path(bld_dir).exists():
        print(f"Cleaning build directory: {bld_dir}")
        subprocess.run(["rm", "-rf", bld_dir], check=True)
    commands = [
        f"mkdir -p {bld_dir}",
        f"cd {bld_dir}",
        "arch=$(dpkg-architecture -qDEB_HOST_MULTIARCH)",
        (f'cmake "{src_dir}" ' + " ".join(settings)),
        "make install",
    ]
    cmd = " && ".join(commands)
    run_command(cmd, "Build Parflow")
    print(f"Parflow built and installed to {ins_dir}")


def ctest(clean=False, bld_dir="build", pattern=None):
    """Run CTest for Parflow."""
    bld_dir = Path(bld_dir).absolute()
    if not bld_dir.exists():
        print(
            f"✗ Error build directory does not exist. Please build Parflow before running CTest.",
            file=sys.stderr,
        )
        sys.exit(1)
    tst_dir = bld_dir / "Testing"
    if clean and tst_dir.exists():
        print(f"Cleaning test directory: {tst_dir}")
        subprocess.run(["rm", "-rf", tst_dir], check=True)
    if pattern:
        commands = [
            f"cd {bld_dir}",
            f'ctest --output-on-failure -R "{pattern}"',
        ]
    else:
        commands = [f"cd {bld_dir}", "ctest --output-on-failure"]
    cmd = " && ".join(commands)
    run_command(cmd, "Run CTest")
    print("CTest completed successfully")


def main():
    parser = argparse.ArgumentParser(
        description="Parflow setup script: download, build, and test",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="Examples:\n"
        "  %(prog)s                  # Build and test (default)\n"
        "  %(prog)s --download       # Download source, build, and test\n"
        "  %(prog)s --download-only  # Download only\n"
        "  %(prog)s --<step>         # Enable <download|build|test>\n"
        "  %(prog)s --no-<step>      # Disable <download|build|test>\n"
        "  %(prog)s --clean-<step>   # Clean <build|test> before step\n",
    )

    # Download options
    parser.add_argument(
        "--download",
        action="store_true",
        default=False,
        help="Download the Parflow repository (default: False)",
    )
    parser.add_argument(
        "--no-download",
        dest="download",
        action="store_false",
        help="Do not download the Parflow repository",
    )
    parser.add_argument(
        "--download-only",
        action="store_true",
        default=False,
        help="Download only, do not build or test",
    )
    # Build options
    parser.add_argument(
        "--build",
        action="store_true",
        default=True,
        help="Build and install Parflow (default: True)",
    )
    parser.add_argument(
        "--no-build",
        dest="build",
        action="store_false",
        help="Do not build and install Parflow",
    )
    # Test options
    parser.add_argument(
        "--test",
        action="store_true",
        default=True,
        help="Run Parflow tests (default: True)",
    )
    parser.add_argument(
        "--no-test", dest="test", action="store_false", help="Do not run Parflow tests"
    )
    parser.add_argument(
        "--test-pattern",
        type=str,
        default="",
        help="Run only tests matching the given pattern (default: all tests)",
    )
    # Clean options
    parser.add_argument(
        "--clean-build",
        action="store_true",
        default=False,
        help="Clean build directory (default: False)",
    )
    parser.add_argument(
        "--clean-test",
        action="store_true",
        default=False,
        help="Clean test directory (default: False)",
    )

    args = parser.parse_args()
    if args.download_only:
        args.download = True
        args.build = False
        args.test = False

    pf_src = Path(os.getenv("DEV_HOME", ".")) / "parflow"
    pf_bld = Path(os.getenv("DEV_HOME", ".")) / "build"
    pf_pfx = Path(os.getenv("PARFLOW_DIR", "."))
    pf_tst = Path(os.getenv("DEV_HOME", ".")) / "test"
    pf_bld_cln = args.clean_build
    pf_tst_cln = args.clean_test
    pf_tst_ptn = args.test_pattern

    # Execute requested operations
    if args.download:
        download(src_dir=pf_src)

    if args.build:
        pf_bld_settings = [
            "-DPARFLOW_AMPS_LAYER=mpi1",
            "-DPARFLOW_AMPS_SEQUENTIAL_IO=TRUE",
            "-DHYPRE_ROOT=$PARFLOW_DEP_DIR",
            "-DSILO_ROOT=$PARFLOW_DEP_DIR",
            "-DPARFLOW_ENABLE_HDF5=TRUE",
            "-DNETCDF_DIR=$PARFLOW_DEP_DIR",
            "-DNETCDF_Fortran_ROOT=$PARFLOW_DEP_DIR",
            "-DPARFLOW_ENABLE_TIMING=TRUE",
            "-DPARFLOW_HAVE_CLM=TRUE",
            "-DPARFLOW_ENABLE_PYTHON=TRUE",
            "-DCURL_LIBRARY=/usr/lib/$arch/libcurl.so.4",
            "-DCMAKE_BUILD_TYPE=Release",
            f"-DCMAKE_INSTALL_PREFIX={pf_pfx.absolute()}",
        ]
        build(
            clean=pf_bld_cln,
            src_dir=pf_src,
            bld_dir=pf_bld,
            settings=pf_bld_settings,
        )

    if args.test:
        ctest(
            clean=pf_tst_cln,
            bld_dir=pf_bld,
            pattern=pf_tst_ptn,
        )

    print(f"\n{'='*60}")
    print("All requested operations completed successfully!")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    main()
