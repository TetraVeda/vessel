"""Rename schema files based on schema SAID removing all other characters."""

import os
import shutil
import sys


def rename_schema(filename, source_directory, target_directory):
    """Rename an individual filename."""
    if filename.endswith(".json"):
        # Remove front label and two underscores
        new_name = filename.split("__", 1)[-1]
        # Remove .json extension
        new_name = new_name.rsplit('.json', 1)[0]
        # Moving the file to the new directory
        shutil.copy(os.path.join(source_directory, filename), os.path.join(target_directory, new_name))


def rename_schemas(source_directory, target_directory):
    """
    Rename schema files to have their schema SAID as their name with no extension.

    Places files in the target_directory.
    """
    # Create the target directory if it doesn't exist
    os.makedirs(target_directory, exist_ok=True)

    for filename in os.listdir(source_directory):
        rename_schema(filename, source_directory, target_directory)


def main():
    """Run main function."""
    if len(sys.argv) < 3:
        print("usage: python rename.py <source_path> <target_path>")
        sys.exit(1)

    # Replace 'results' with the path to your source directory
    source_path = sys.argv[1]
    # Path to the target directory
    target_path = sys.argv[2]
    rename_schemas(source_path, target_path)


if __name__ == "__main__":
    main()
