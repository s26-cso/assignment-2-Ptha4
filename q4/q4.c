#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <string.h>

int main() {
    // for names <= 5 
    char op[8];
    // ints
    int num1, num2;
    // pointer to dyn loaded shared lib
    void *handle = NULL;
    // pointer to func in the lib 
    int (*operation)(int, int);
    // stores the path to the lib to be loaded(libop.so)
    char lib_path[20];

    while (scanf("%s %d %d", op, &num1, &num2) == 3) {
        // mkae lib path
        snprintf(lib_path, sizeof(lib_path), "./lib%s.so", op);
        // load lib to memory
        handle = dlopen(lib_path, RTLD_NOW);
        // if lib not found
        if (!handle) {
            continue;
        }
        //finds the function by name in the loaded lib and returns a pointer to it
        operation = (int (*)(int, int)) dlsym(handle, op);
        
        if (operation) {
            // execute function using operation(num1, num2)
            printf("%d\n", operation(num1, num2));
            fflush(stdout);
        }
        // unload the library
        dlclose(handle);
    }

    return 0;
}