# Usage

`update_cursor_ips.py` updates a plain text file that stores one IP address per
line.

## Example

Create an input file:

```text
192.168.0.10
10.0.0.5
```

Run the script:

```bash
python3 update_cursor_ips.py --file ips.txt --add 203.0.113.7 --remove 10.0.0.5
```

Result:

```text
192.168.0.10
203.0.113.7
```

## Validation

The script accepts only valid IPv4 and IPv6 addresses. Duplicate addresses are
removed automatically and the output is sorted.
