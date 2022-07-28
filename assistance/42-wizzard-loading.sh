#!/bin/zsh

animation_frame_interval=0.2

# loadig animation arrays
classic=('-' "\\" '|' '/' )

metro=( '[                        ]'
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

declare -a loading_animation

play_loading_animation_loop() {
  while true ; do
    for frame in "${loading_animation[@]}" ; do
      printf "\r%s" "${frame}"
      sleep 0.1
    done
  done
}

start_loading_animation() {
  loading_animation=( "${@}" )
  # echo ${loading_animation[@]}
  # echo "BLA_active_loading_animation: ${BLA_active_loading_animation[@]}"
  # Extract the delay between each frame from array BLA_active_loading_animation
  # echo "BLA_loading_animation_frame_interval: ${BLA_loading_animation_frame_interval}"
  #echo ${BLA_active_loading_animation[@]}
  # exit 0
  tput civis # Hide the terminal cursor
  play_loading_animation_loop &
  loading_animation_pid="${!}"
}

stop_loading_animation() {
  kill "${loading_animation_pid}" &> /dev/null
  printf "\n"
  tput cnorm # Restore the terminal cursor
}
