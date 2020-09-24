import os

def cleanup(folder):
    to_remove = os.listdir(folder)
    for file in to_remove:
        if not file.startswith('.'):
            path_to_file = os.path.join(folder, file)
            os.remove(path_to_file)