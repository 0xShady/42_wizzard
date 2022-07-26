"$@" &

while kill -0 $! 2> dev; do
    printf . > /dev/tty
    sleep 0.5
done

printf '\n' > /dev/tty
