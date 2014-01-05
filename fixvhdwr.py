import sys

if __name__ == "__main__":
    ifile = sys.argv[1]
    ofile = sys.argv[2]
    offset = int(sys.argv[3])

    f1 = open(ifile, 'r')
    block = f1.read(512)

    f2 = open(ofile, 'r+')
    f2.seek(512*offset)
    f2.write(block)

    f1.close()
    f2.close()
