#include <unistd.h>

__attribute__((noinline, optnone)) void h0_export_ready(void) {
    __asm__ volatile("" ::: "memory");
}

int main(void) {
    // This private pipe token announces readiness; it is not user content.
    if (write(STDOUT_FILENO, "R", 1) != 1) return 3;
    char task_token;
    if (read(STDIN_FILENO, &task_token, 1) != 1) return 2;
    h0_export_ready();
    return 0;
}
