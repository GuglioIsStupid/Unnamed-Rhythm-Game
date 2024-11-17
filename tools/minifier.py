# lua code minifier
# removes all comments, and minifies variable names
# usage: python minifier.py <input.lua> <output.lua>
# if output is not specified, it will write to mini/<input.lua>
import sys, re, os

ignoreFiles = [
    # Breaks when minified for some reason
    "Yaml.lua" 
]

globalVars = {
    'love': 'love',
    'jit': 'jit',
    'math': 'math',
    'table': 'table',
    'string': 'string',
    'io': 'io',
    'os': 'os',
    'debug': 'debug',
    'coroutine': 'coroutine',
}
currentChar = "a" # a-z, then A-Z, then aa-az, then aA-aZ, then ba-bz, etc

def minify(input, output):
    with open(input, 'r') as f:
        lua = f.read()

    lua = re.sub(r'--\[\[.*?\]\]', '', lua, flags=re.DOTALL)
    lua = re.sub(r'--\[=*\[.*?\]=*\]', '', lua, flags=re.DOTALL)
    lua = re.sub(r'--.*', '', lua)

    # remove whitespace
    lua = re.sub(r'\s+', ' ', lua)

    # TODO: minify variable names
   
    os.makedirs(os.path.dirname(output), exist_ok=True)
    with open(output, 'w') as f:
        f.write(lua)

def checkFolder(folder):
    for root, dirs, files in os.walk(folder):
        for file in files:
            if file.endswith('.lua') and file not in ignoreFiles:
                minify(os.path.join(root, file), os.path.join('mini', root, file))
            elif (not file.endswith('.lua') or file in ignoreFiles) and not os.path.exists(os.path.join('mini', root, file)):
                os.makedirs(os.path.join('mini', root), exist_ok=True)
                os.system('cp "{}" "{}"'.format(os.path.join(root, file), os.path.join('mini', root, file)))

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('usage: python minifier.py <folder>')
        sys.exit(1)

    folder = sys.argv[1]
    
    checkFolder(folder)