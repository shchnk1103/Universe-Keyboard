#include <errno.h>
#include <stdio.h>
#include <unistd.h>

__attribute__((noinline, optnone)) void h0_export_ready(void) {
    __asm__ volatile("" ::: "memory");
}

int main(void) {
    // This private pipe token announces readiness; it is not user content.
    if (write(STDOUT_FILENO, "R", 1) != 1) return 3;
    char task_token;
    // Debugger attach can interrupt the wait; tolerate only one confirmed EINTR.
    for (unsigned int attempt = 1; attempt <= 2; ++attempt) {
        errno = 0;
        const ssize_t read_result = read(STDIN_FILENO, &task_token, 1);
        const int read_error = read_result < 0 ? errno : 0;
        fprintf(stderr, "read_attempt=%u read_return=%ld errno=%d\n",
                attempt, (long)read_result, read_error);
        if (read_result == 1) break;
        if (read_result < 0 && read_error == EINTR && attempt < 2) continue;
        return 2;
    }
    h0_export_ready();
    return 0;
}
