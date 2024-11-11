#!/bin/bash

# Fungsi untuk memeriksa aplikasi yang diperlukan
function check_dependencies() {
    dependencies=("tldr" "dpkg" "man")

    echo "Memeriksa aplikasi yang diperlukan..."
    for dep in "${dependencies[@]}"; do
        if ! command -v $dep &> /dev/null; then
            echo "$dep belum terinstal."
            read -p "Ingin menginstal $dep? (y/n): " install_choice
            if [[ $install_choice == "y" ]]; then
                if command -v apt-get &> /dev/null; then
                    sudo apt-get install -y $dep
                elif command -v yum &> /dev/null; then
                    sudo yum install -y $dep
                else
                    echo "Manajer paket tidak ditemukan. Silakan instal $dep secara manual."
                fi
            fi
        else
            echo "$dep sudah terinstal."
        fi
    done
    echo "Pemeriksaan selesai."
    echo ""
}

# Panggil fungsi pemeriksaan saat program dimulai
check_dependencies

# Fungsi untuk menampilkan menu utama
function show_menu() {
    echo "Pilih Menu:"
    echo "1. Daftar Perintah"
    echo "2. Fungsi Perintah"
    echo "3. Pencarian Perintah"
    echo "4. Daftar Aplikasi Terinstal"
    echo "5. Riwayat Perintah Terakhir"
    echo "6. Simpan Daftar Perintah ke Log"
    echo "7. Periksa Perintah Apakah Terinstal"
    echo "8. Bantuan Cepat dengan tldr"
    echo "9. Daftar Perintah Berdasarkan Kategori"
    echo "10. Keluar"
}

# Fungsi untuk menampilkan semua perintah yang tersedia di sistem
function list_commands() {
    echo "Daftar semua perintah yang tersedia di sistem:"
    compgen -c | sort | uniq
    echo ""
}

# Fungsi untuk menampilkan deskripsi singkat perintah
function command_help() {
    read -p "Masukkan perintah yang ingin Anda ketahui fungsinya: " cmd
    echo ""

    if command -v $cmd > /dev/null; then
        echo "Deskripsi untuk perintah '$cmd':"
        man -f $cmd || $cmd --help || whatis $cmd
    else
        echo "Perintah '$cmd' tidak ditemukan di sistem."
    fi
}

# Fungsi untuk mencari perintah berdasarkan kata kunci
function search_commands() {
    read -p "Masukkan kata kunci untuk mencari perintah: " keyword
    echo "Hasil pencarian untuk perintah yang mengandung '$keyword':"
    compgen -c | grep -i "$keyword" | sort | uniq
    echo ""
}

# Fungsi untuk menampilkan aplikasi yang terinstal
function list_installed_apps() {
    echo "Daftar aplikasi yang terinstal:"
    dpkg -l | awk '{print $2}' | sort
    echo ""
}

# Fungsi untuk menampilkan riwayat perintah terakhir
function show_history() {
    echo "Riwayat perintah yang digunakan:"
    history | tail -n 10
    echo ""
}

# Fungsi untuk menyimpan output ke dalam file log
function interactive_save() {
    read -p "Ingin menyimpan output ke file (y/n)? " save
    if [[ $save == "y" ]]; then
        read -p "Masukkan nama file (default: output_log.txt): " filename
        filename=${filename:-output_log.txt}
        list_commands > "$filename"
        echo "Output disimpan di $filename."
    fi
}

# Fungsi untuk memeriksa apakah perintah tersedia di sistem
function check_command_installed() {
    read -p "Masukkan perintah yang ingin diperiksa: " cmd
    if command -v $cmd > /dev/null; then
        echo "Perintah '$cmd' ditemukan di sistem."
    else
        echo "Perintah '$cmd' tidak ditemukan. Anda mungkin perlu menginstalnya."
    fi
}

# Fungsi untuk menampilkan bantuan cepat dengan tldr
function command_quick_help() {
    read -p "Masukkan perintah untuk info cepat: " cmd
    if command -v tldr > /dev/null; then
        tldr $cmd || echo "Dokumentasi tidak tersedia untuk '$cmd'."
    else
        echo "tldr tidak terinstal. Silakan instal dengan 'sudo apt install tldr'."
    fi
}

# Fungsi untuk menampilkan daftar perintah berdasarkan kategori
function list_commands_by_category() {
    echo "Pilih kategori perintah:"
    echo "1. Manipulasi File (cp, mv, rm)"
    echo "2. Perintah Sistem (top, ps, uname)"
    echo "3. Jaringan (ping, ifconfig, netstat)"
    echo "4. Semua Perintah"

    read -p "Pilih kategori (1-4): " category
    case $category in
        1) compgen -c | grep -E "cp|mv|rm|ls|mkdir|touch" | sort | uniq ;;
        2) compgen -c | grep -E "top|ps|uname|uptime|df" | sort | uniq ;;
        3) compgen -c | grep -E "ping|ifconfig|netstat|curl|wget" | sort | uniq ;;
        4) compgen -c | sort | uniq ;;
        *) echo "Kategori tidak valid." ;;
    esac
    echo ""
}

# Loop utama program
while true; do
    show_menu
    read -p "Masukkan pilihan Anda: " choice
    echo ""

    case $choice in
        1) list_commands ;;
        2) command_help ;;
        3) search_commands ;;
        4) list_installed_apps ;;
        5) show_history ;;
        6) interactive_save ;;
        7) check_command_installed ;;
        8) command_quick_help ;;
        9) list_commands_by_category ;;
        10)
            echo "Keluar dari program."
	    echo "Mohon Bantuan saran dan koreksi nya supaya program ini bisa semakin maksimal"
            break
            ;;
        *)
            echo "Pilihan tidak valid, coba lagi."
            ;;
    esac
    echo ""
done
