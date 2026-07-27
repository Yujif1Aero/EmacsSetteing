ChatGPT





チームメンバーを招待する
30s考えました
一番多い原因は、まだ 127.0.0.1 だけで待ち受けている／UFWで遮断されている／Viewerの入力形式が違うのどれかです。

Ubuntu側で、いったん確実に再起動してください。

pkill -x X0tigervnc 2>/dev/null || true
rm -f "$HOME/.vnc/"*:1.pid

x0tigervncserver \
  -display :1 \
  -rfbport 5901 \
  -PasswordFile "$HOME/.config/tigervnc/passwd" \
  -SecurityTypes VncAuth \
  -localhost no
TigerVNCのUbuntu版ラッパーは -localhost yes|no と -rfbport をサポートしています。

次に待受アドレスを確認します。

ss -ltnp | grep 5901
正常なら、次のどちらかが出ます。

0.0.0.0:5901
または：

[::]:5901
これでは外部接続できません。

127.0.0.1:5901
ファイアウォールを開ける
sudo ufw status verbose
sudo ufw allow 5901/tcp
sudo ufw reload
UbuntuのIPアドレスを確認します。

hostname -I
例えば 192.168.1.50 なら、接続元の入力はViewerによって異なります。

TigerVNC Viewerの場合

192.168.1.50::5901
TigerVNCは host::port 形式に対応しています。

RealVNC Viewer 7.10の場合

192.168.1.50:1
RealVNCでは HOST:DISPLAY 形式で、ディスプレイ :1 がポート5901に対応します。192.168.1.50:5901 ではありません。

接続元がWindowsなら、Viewerを開く前にPowerShellで通信確認できます。

Test-NetConnection 192.168.1.50 -Port 5901
結果が以下ならネットワークは通っています。

TcpTestSucceeded : True
False なら、VNC認証以前の問題です。Ubuntu側の ss -ltnp | grep 5901、sudo ufw status verbose、接続元の Test-NetConnection の3つの結果を確認してください。


つながった！ubuntu側でタイガーを起動するスクリプトを書いて（sshでアクセスしますのが注意）

Thinking を停止しました

つながった！ubuntu側でタイガーを起動するスクリプトを書いて（sshでアクセスしますのが注意）
つなげたあとhost先のディスプレイの解像度を直したい

1m 21s考えました
SSH経由でも、物理GNOMEセッションのDISPLAYとXAUTHORITYを自動検出するスクリプトを作成しました。

tigervnc-host.sh

Ubuntuへ配置
接続元PCから転送する場合：

scp tigervnc-host.sh ubuntu@UbuntuのIP:~/
UbuntuへSSH接続して実行権限を付けます。

ssh ubuntu@UbuntuのIP
chmod +x ~/tigervnc-host.sh
TigerVNCを起動
~/tigervnc-host.sh start
このスクリプトは以下を自動で行います。

SSH側の$DISPLAYを使わず、アクティブなローカルX11セッションを検出

GNOME ShellからXAUTHORITYを検出

既に5901番で起動していないか確認

-localhost noで外部接続を許可

SSH切断後も動くようにnohupで起動

ログを~/.local/state/tigervnc/x0tigervnc.logへ保存

x0vncserverは仮想画面を作らず、物理モニターにつながった既存のX画面を共有します。

状態確認：

~/tigervnc-host.sh status
停止：

~/tigervnc-host.sh stop
ログ確認：

tail -f ~/.local/state/tigervnc/x0tigervnc.log
接続先は通常：

UbuntuのIP::5901
ホスト側の解像度を変更
まず利用可能な出力名と解像度を確認します。

~/tigervnc-host.sh outputs
例えば、現在のプライマリモニターを1920×1080にします。

~/tigervnc-host.sh resolution 1920x1080
出力を指定する場合：

~/tigervnc-host.sh resolution 1920x1080 HDMI-1
リフレッシュレートも指定できます。

~/tigervnc-host.sh resolution 2560x1440@60 HDMI-1
指定した解像度が未登録の場合、スクリプトはcvtでモードを生成し、xrandr --newmodeと--addmodeで追加を試みます。xrandrは出力のモード選択や新しいモードの追加に対応しています。

cvtがない場合：

sudo apt update
sudo apt install xcvt
Ubuntuではcvtユーティリティがxcvtパッケージとして提供されています。

注意点
この構成では、VNC画面だけでなくUbuntuの物理モニターの解像度も変わります。x0TigerVNCは既存のX画面をそのまま共有するためです。VNC Viewerのウィンドウだけ見やすくしたい場合は、Viewer側のスケーリング機能を使ってください。

また、スクリプトの既定値は接続互換性を優先してVncAuthです。インターネットへ5901番を直接公開せず、LANまたはVPN内に限定してください。例えばLANが192.168.1.0/24なら：

sudo ufw delete allow 5901/tcp 2>/dev/null || true
sudo ufw allow from 192.168.1.0/24 to any port 5901 proto tcp
sudo ufw status


real vnc サーバーをインスールしてしまったので消す方法を教えて.atp remove?

ライブラリ
/
tigervnc-host.sh


#!/usr/bin/env bash
set -Eeuo pipefail

# SSH から、ログイン中の GNOME/Xorg セッションを検出して
# x0tigervncserver の起動・停止・解像度変更を行う。
#
# Usage:
#   ./tigervnc-host.sh start
#   ./tigervnc-host.sh stop
#   ./tigervnc-host.sh status
#   ./tigervnc-host.sh outputs
#   ./tigervnc-host.sh resolution 1920x1080
#   ./tigervnc-host.sh resolution 2560x1440 HDMI-1
#
# Environment variables:
#   VNC_PORT=5901
#   VNC_PASSFILE=$HOME/.config/tigervnc/passwd
#   VNC_SECURITY_TYPES=VncAuth

VNC_PORT="${VNC_PORT:-5901}"
VNC_PASSFILE="${VNC_PASSFILE:-$HOME/.config/tigervnc/passwd}"
VNC_SECURITY_TYPES="${VNC_SECURITY_TYPES:-VncAuth}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/tigervnc"
LOG_FILE="$STATE_DIR/x0tigervnc.log"

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

need_command() {
    command -v "$1" >/dev/null 2>&1 || die "コマンドがありません: $1"
}

session_property() {
    local session_id="$1"
    local property="$2"
    loginctl show-session "$session_id" --property="$property" --value 2>/dev/null || true
}

find_graphical_session() {
    local session_id
    local name type active remote seat display
    local fallback_session=""
    local fallback_display=""

    while read -r session_id _; do
        [[ -n "$session_id" ]] || continue

        name="$(session_property "$session_id" Name)"
        type="$(session_property "$session_id" Type)"
        active="$(session_property "$session_id" Active)"
        remote="$(session_property "$session_id" Remote)"
        seat="$(session_property "$session_id" Seat)"
        display="$(session_property "$session_id" Display)"

        [[ "$name" == "$USER" ]] || continue
        [[ "$type" == "x11" ]] || continue
        [[ "$active" == "yes" ]] || continue
        [[ "$remote" == "no" ]] || continue
        [[ -n "$display" ]] || continue

        # 物理画面は通常 seat0。見つかったら最優先する。
        if [[ "$seat" == "seat0" ]]; then
            GRAPHICAL_SESSION="$session_id"
            GRAPHICAL_DISPLAY="$display"
            return 0
        fi

        fallback_session="$session_id"
        fallback_display="$display"
    done < <(loginctl list-sessions --no-legend)

    if [[ -n "$fallback_session" ]]; then
        GRAPHICAL_SESSION="$fallback_session"
        GRAPHICAL_DISPLAY="$fallback_display"
        return 0
    fi

    return 1
}

find_xauthority() {
    local uid pid candidate

    uid="$(id -u)"

    # GNOME Shell の環境から取得するのが最も確実。
    while read -r pid; do
        [[ -n "$pid" ]] || continue
        candidate="$(
            tr '\0' '\n' <"/proc/$pid/environ" 2>/dev/null |
                sed -n 's/^XAUTHORITY=//p' |
                head -n 1
        )"
        if [[ -n "$candidate" && -r "$candidate" ]]; then
            GRAPHICAL_XAUTHORITY="$candidate"
            return 0
        fi
    done < <(pgrep -u "$uid" -x gnome-shell 2>/dev/null || true)

    for candidate in \
        "/run/user/$uid/gdm/Xauthority" \
        "$HOME/.Xauthority"
    do
        if [[ -r "$candidate" ]]; then
            GRAPHICAL_XAUTHORITY="$candidate"
            return 0
        fi
    done

    return 1
}

prepare_graphical_environment() {
    need_command loginctl
    need_command xrandr

    find_graphical_session ||
        die "このユーザーのアクティブなGNOME/Xorgセッションが見つかりません。GNOMEへログイン済みか、WaylandではなくXorgか確認してください。"

    find_xauthority ||
        die "XAUTHORITYが見つかりません。SSHユーザーとGNOMEログインユーザーが同じか確認してください。"

    export DISPLAY="$GRAPHICAL_DISPLAY"
    export XAUTHORITY="$GRAPHICAL_XAUTHORITY"

    xrandr --query >/dev/null 2>&1 ||
        die "X画面 $DISPLAY にアクセスできません。XAUTHORITY=$XAUTHORITY"
}

port_is_listening() {
    ss -ltnH 2>/dev/null |
        awk -v port=":${VNC_PORT}" '$4 ~ port"$" { found=1 } END { exit !found }'
}

start_server() {
    need_command x0tigervncserver
    need_command ss
    prepare_graphical_environment

    [[ -r "$VNC_PASSFILE" ]] ||
        die "パスワードファイルがありません: $VNC_PASSFILE
作成例: tigervncpasswd \"$VNC_PASSFILE\""

    chmod 600 "$VNC_PASSFILE"
    mkdir -p "$STATE_DIR"

    if port_is_listening; then
        printf 'TigerVNCはすでにTCP %s番で待受中です。\n' "$VNC_PORT"
        status_server
        return 0
    fi

    printf 'GNOME session : %s\n' "$GRAPHICAL_SESSION"
    printf 'X display     : %s\n' "$DISPLAY"
    printf 'XAUTHORITY    : %s\n' "$XAUTHORITY"
    printf 'VNC port      : %s\n' "$VNC_PORT"
    printf 'Log           : %s\n' "$LOG_FILE"

    # nohupによりSSH切断後も起動を維持する。
    nohup x0tigervncserver \
        -display "$DISPLAY" \
        -rfbport "$VNC_PORT" \
        -PasswordFile "$VNC_PASSFILE" \
        -SecurityTypes "$VNC_SECURITY_TYPES" \
        -localhost no \
        >"$LOG_FILE" 2>&1 </dev/null &

    # ラッパーがデーモン化する場合にも対応して、ポートで成功判定する。
    local i
    for i in {1..20}; do
        if port_is_listening; then
            printf '起動しました。接続先: <UbuntuのIP>::%s\n' "$VNC_PORT"
            return 0
        fi
        sleep 0.25
    done

    printf '%s\n' '--- log ---' >&2
    tail -n 50 "$LOG_FILE" >&2 || true
    die "TigerVNCの起動を確認できませんでした。"
}

stop_server() {
    need_command x0tigervncserver

    if find_graphical_session; then
        x0tigervncserver -kill "$GRAPHICAL_DISPLAY" 2>/dev/null || true
    fi

    # 残っている同一ユーザーのX0TigerVNCプロセスも終了する。
    pkill -u "$(id -u)" -x X0tigervnc 2>/dev/null || true
    pkill -u "$(id -u)" -x x0vncserver 2>/dev/null || true

    sleep 0.5
    if command -v ss >/dev/null 2>&1 && port_is_listening; then
        die "TCP $VNC_PORT 番がまだ使用中です。sudo ss -ltnp | grep :$VNC_PORT で確認してください。"
    fi

    printf '停止しました。\n'
}

status_server() {
    need_command ss

    printf '%s\n' '--- process ---'
    pgrep -a -u "$(id -u)" -f 'X0tigervnc|x0vncserver' || true

    printf '%s\n' '--- listening port ---'
    ss -ltnp 2>/dev/null |
        awk -v port=":${VNC_PORT}" 'NR==1 || $4 ~ port"$"' || true

    printf '%s\n' '--- graphical session ---'
    if find_graphical_session; then
        printf 'session=%s display=%s\n' "$GRAPHICAL_SESSION" "$GRAPHICAL_DISPLAY"
    else
        printf 'アクティブなX11セッションなし\n'
    fi
}

show_outputs() {
    prepare_graphical_environment
    xrandr --query
}

mode_exists_for_output() {
    local output="$1"
    local mode="$2"

    xrandr --query |
        awk -v wanted_output="$output" -v wanted_mode="$mode" '
            $1 == wanted_output && $2 == "connected" {
                inside = 1
                next
            }
            inside && ($2 == "connected" || $2 == "disconnected") {
                inside = 0
            }
            inside && $1 == wanted_mode {
                found = 1
            }
            END {
                exit found ? 0 : 1
            }
        '
}

create_mode() {
    local requested="$1"
    local output="$2"
    local width height refresh modeline quoted_name mode_name rest
    local -a modeline_args

    if [[ ! "$requested" =~ ^([0-9]+)x([0-9]+)(@([0-9]+([.][0-9]+)?))?$ ]]; then
        die "未登録モードは WIDTHxHEIGHT または WIDTHxHEIGHT@Hz で指定してください。例: 1920x1080@60"
    fi

    width="${BASH_REMATCH[1]}"
    height="${BASH_REMATCH[2]}"
    refresh="${BASH_REMATCH[4]:-60}"

    command -v cvt >/dev/null 2>&1 ||
        die "カスタム解像度の生成にはcvtが必要です: sudo apt install xcvt"

    modeline="$(cvt "$width" "$height" "$refresh" | awk '/^Modeline / { sub(/^Modeline /, ""); print; exit }')"
    [[ -n "$modeline" ]] || die "cvtでModelineを生成できませんでした。"

    read -r quoted_name rest <<<"$modeline"
    mode_name="${quoted_name#\"}"
    mode_name="${mode_name%\"}"
    read -r -a modeline_args <<<"$rest"

    # 既にグローバル登録済みなら --newmode の失敗を無視する。
    xrandr --newmode "$mode_name" "${modeline_args[@]}" 2>/dev/null || true
    xrandr --addmode "$output" "$mode_name" 2>/dev/null || true

    printf '%s\n' "$mode_name"
}

set_resolution() {
    local requested="${1:-}"
    local requested_output="${2:-}"
    local output primary actual_mode
    local -a connected_outputs

    [[ -n "$requested" ]] ||
        die "解像度を指定してください。例: $0 resolution 1920x1080"

    prepare_graphical_environment

    mapfile -t connected_outputs < <(
        xrandr --query | awk '$2 == "connected" { print $1 }'
    )
    ((${#connected_outputs[@]} > 0)) ||
        die "接続済みディスプレイ出力がありません。"

    primary="$(
        xrandr --query |
            awk '$2 == "connected" && $3 == "primary" { print $1; exit }'
    )"

    output="${requested_output:-${primary:-${connected_outputs[0]}}}"

    printf '%s\n' "${connected_outputs[@]}" | grep -Fxq "$output" ||
        die "出力 $output は接続されていません。'$0 outputs' で確認してください。"

    if mode_exists_for_output "$output" "$requested"; then
        actual_mode="$requested"
    else
        printf 'モード %s は未登録なので追加を試みます。\n' "$requested"
        actual_mode="$(create_mode "$requested" "$output")"
    fi

    xrandr --output "$output" --mode "$actual_mode"

    printf '変更しました: output=%s mode=%s display=%s\n' \
        "$output" "$actual_mode" "$DISPLAY"
}

usage() {
    cat <<EOF
Usage:
  $0 start
  $0 stop
  $0 status
  $0 outputs
  $0 resolution WIDTHxHEIGHT [OUTPUT]
  $0 resolution WIDTHxHEIGHT@Hz [OUTPUT]

Examples:
  $0 start
  $0 outputs
  $0 resolution 1920x1080
  $0 resolution 2560x1440@60 HDMI-1

Environment:
  VNC_PORT=$VNC_PORT
  VNC_PASSFILE=$VNC_PASSFILE
  VNC_SECURITY_TYPES=$VNC_SECURITY_TYPES
EOF
}

case "${1:-}" in
    start)
        start_server
        ;;
    stop)
        stop_server
        ;;
    status)
        status_server
        ;;
    outputs)
        show_outputs
        ;;
    resolution)
        set_resolution "${2:-}" "${3:-}"
        ;;
    -h|--help|help|"")
        usage
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac
