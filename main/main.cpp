#include <print>

#include <Windows.h>
#include <VersionHelpers.h>

int main() {
    std::println("Hello world!");
    if (IsWindows10OrGreater()) {
        std::println("Windows 10!");
    } else if (IsWindows8Point1OrGreater()) {
        std::println("Windows 8.1!");
    } else if (IsWindows8OrGreater()) {
        std::println("Windows 8!");
    } else if (IsWindows7OrGreater()) {
        std::println("Windows 7!");
    } else if (IsWindowsVistaOrGreater()) {
        std::println("Windows Vista!");
    } else {
        std::println("Windows XP (or older)!");
    }
    std::ignore = MessageBox(nullptr, TEXT("Hello world!"), TEXT("Hello world!"), MB_OK | MB_ICONINFORMATION);
    return 0;
}
