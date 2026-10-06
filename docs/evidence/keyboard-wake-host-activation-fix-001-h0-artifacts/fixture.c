#include <unistd.h>

// Wait for a task-owned pipe token before the only dedicated breakpoint.
__attribute__((noinline, optnone)) void h0_export_ready(void) {
    __asm__ volatile("" ::: "memory");
}

int main(void) {
    char task_token;
    if (read(STDIN_FILENO, &task_token, 1) != 1) return 2;
    h0_export_ready();
    return 0;
}
