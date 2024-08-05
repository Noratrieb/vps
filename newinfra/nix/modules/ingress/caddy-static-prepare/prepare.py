import os
import sys
import gzip
import brotli
import zstandard
import hashlib


def usage():
    print("usage: prepare.py [SRC]")


def write_etag(path, content):
    shasum = hashlib.sha256(content)
    etag_path = path+".sha256"
    with open(etag_path, "w") as f:
        print(f"Writing ETag {etag_path}")
        f.write(f'"{shasum.hexdigest()}"')


def main():
    if len(sys.argv) < 2:
        usage()
        exit(1)

    src_dir = sys.argv[1]

    for root, dirs, files in os.walk(src_dir):
        for file in files:
            path = os.path.join(root, file)

            # Ignore etags
            if path.endswith(".sha256") or path.endswith(".b3sum"):
                continue

            # Ignore already compressed files        
            if path.endswith(".gz") or path.endswith(".zst") or path.endswith(".br"):
                continue

            with open(path, "rb") as f:
                content = f.read()

            compressions = [
                (".gz", gzip),
                (".zst", zstandard),
                (".br", brotli),
            ]

            for ext, alg in compressions:
                new_path = path+ext
                with open(new_path, "wb") as out:
                    print(f"Writing {new_path}")
                    compressed = alg.compress(content)
                    out.write(compressed)
                    write_etag(new_path, compressed)

            write_etag(path, content)

if __name__ == "__main__":
    main()