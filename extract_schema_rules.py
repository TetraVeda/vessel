#!/usr/bin/env python
"""Extract rules section from ACDC JSONSchema."""
import json
import os
import sys
import subprocess


def parse_rules_section(json_schema):
    """Parse JSON Schema rules and extract them."""
    # Assuming 'r' is always present in the schema
    rules_section = json_schema.get('properties', {}).get('r', {}).get('oneOf', [])
    for rule_option in rules_section:
        if 'properties' in rule_option:
            rules_data = rule_option['properties']
            parsed_rules = {}
            for key, value in rules_data.items():
                # Handle nested properties with const value
                if 'properties' in value:
                    inner_properties = value['properties']
                    for inner_key, inner_value in inner_properties.items():
                        const_value = inner_value.get('const')
                        if const_value is not None:
                            parsed_rules.setdefault(key, {})[inner_key] = const_value
                # handle properties without nested properties
                else:
                    parsed_rules[key] = value.get('const', '')
            return parsed_rules
    return {}


def extract_rules(file_name, output_file):
    """Extract rules from single JSONSchema file an write to file."""
    # Open input file and parse
    try:
        with open(file_name, 'r') as schema_file:
            schema = json.load(schema_file)
        rules_data_model = parse_rules_section(schema)
        with open(output_file, 'w') as rules_file:
            json.dump(rules_data_model, rules_file, indent=2)
    except FileNotFoundError:
        print(f"File not found: {file_name}")
    except json.JSONDecodeError:
        print(f"Invalid JSON in file: {file_name}")
    except UnicodeDecodeError:
        print(f"Invalid encoding in file: {file_name}")
        return

    # SAIDification
    cmd = ["kli", "saidify", "--file", output_file]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.stderr:
        print(f"Error: {result.stderr}")


def main():
    """Run rule extractor."""
    if len(sys.argv) < 3:
        print("Usage: rule_extractor.py <source_path> <target_path>")
        sys.exit(1)

    source_path = sys.argv[1]
    target_path = sys.argv[2]

    os.makedirs(source_path, exist_ok=True)
    os.makedirs(target_path, exist_ok=True)

    file_names = [f for f in os.listdir(source_path) if f.endswith('.json')]
    for name in file_names:
        input_file = os.path.join(source_path, name)
        output_file = os.path.join(
            target_path,
            f"{os.path.splitext(name)[0]}-rules.json"
        )
        extract_rules(input_file, output_file)


if __name__ == "__main__":
    main()
