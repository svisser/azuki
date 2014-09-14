. ./sharness.sh
export PYTHONPATH="$SHARNESS_BUILD_DIRECTORY/lib:$PYTHONPATH"
export PATH="$SHARNESS_BUILD_DIRECTORY/bin:$PATH"

export test_tube="azuki-test-$this_test"

clean_tubes() {
    for tube in $(azuki tubes); do
        case $tube in
            azuki-test-*)
                submit_test_job
                while azuki stats $tube | grep -q 'Delayed: *[1-9]'; do
                    echo delete | azuki peek-delayed --ask $test_tube > /dev/null
                done
                azuki kick 10000 $tube
                azuki foreach $tube /bin/true > /dev/null
                ;;
        esac
    done
}

job_counter=0
submit_test_job() {
    job_counter=$(expr $job_counter + 1)
    echo "test job $job_counter" | azuki put "$@" "$test_tube"
}
