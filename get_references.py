import re
import sys
import errno
import os

pattern = re.compile(r"\[[^[]*]\(([^)]*)\)")

doc_relevant = set()

for arg in sys.argv[1:]:

    if not os.path.exists(arg):
        raise FileNotFoundError(errno.ENOENT, os.strerror(errno.ENOENT), arg)
    else:
        (dirname, basename) = os.path.split(arg)

    doc_relevant.add(arg)

    for i, line in enumerate(open(arg)):
        for match in re.finditer(pattern, line):
            for group in match.groups():
                doc_relevant.add(arg)

for item in doc_relevant:
    print(item)
