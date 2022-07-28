#!/bin/zsh

# "$@" &

# while kill -0 $! 2> dev; do
#     printf . > /dev/tty
#     sleep 0.5
# done

# printf '\n' > /dev/tty

BLA_classic=( 0.25 '-' "\\" '|' '/' )

BLA_metro=( 1   '[                        ]'
                '[=                       ]'
                '[==                      ]'
                '[===                     ]'
                '[====                    ]'
                '[=====                   ]'
                '[======                  ]'
                '[=======                 ]'
                '[========                ]'
                '[=========               ]'
                '[==========              ]'
                '[===========             ]'
                '[============            ]'
                '[ ============           ]'
                '[  ============          ]'
                '[   ============         ]'
                '[    ============        ]'
                '[     ============       ]'
                '[      ============      ]'
                '[       ============     ]'
                '[        ============    ]'
                '[         ============   ]'
                '[          ============  ]'
                '[           ============ ]'
                '[            ============]'
                '[             ===========]'
                '[              ==========]'
                '[               =========]'
                '[                ========]'
                '[                 =======]'
                '[                  ======]'
                '[                   =====]'
                '[                    ====]'
                '[                     ===]'
                '[                      ==]'
                '[                       =]' )

declare -a BLA_active_loading_animation

BLA::play_loading_animation_loop() {
  while true ; do
    for frame in "${BLA_active_loading_animation[@]}" ; do
      printf "\r%s" "${frame}"
      sleep "${BLA_loading_animation_frame_interval}"
    done
  done
}

BLA::start_loading_animation() {
  BLA_active_loading_animation=( "${@}" )
  echo "BLA_active_loading_animation: ${BLA_active_loading_animation[@]}"
  # Extract the delay between each frame from array BLA_active_loading_animation
  BLA_loading_animation_frame_interval=(${BLA_active_loading_animation[0]})
  echo "BLA_loading_animation_frame_interval: ${BLA_loading_animation_frame_interval}"
  BLA_active_loading_animation=("${BLA_active_loading_animation[@]:1}")
#   echo ${BLA_active_loading_animation[@]}
  exit 0
  tput civis # Hide the terminal cursor
  BLA::play_loading_animation_loop &
  BLA_loading_animation_pid="${!}"
}

BLA::stop_loading_animation() {
  kill "${BLA_loading_animation_pid}" &> /dev/null
  printf "\n"
  tput cnorm # Restore the terminal cursor
}
