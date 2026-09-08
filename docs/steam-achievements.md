# Land of Magic (LivingMansion) — Steam Achievements

---

## Stats

| API Name | Type | Description |
|----------|------|-------------|
| `STAT_ROOMS_ENTERED` | INT | Total rooms entered |
| `STAT_CLUES_FOUND` | INT | Total clues discovered |
| `STAT_RUNS_COMPLETED` | INT | Total investigation runs completed |
| `STAT_OBJECTS_EXAMINED` | INT | Total objects examined |
| `STAT_DOORS_OPENED` | INT | Total doors opened |
| `STAT_DANGER_ROOMS_SURVIVED` | INT | High-danger rooms survived |

---

## Achievements

| API Name | EN Name | KO Name | How to Unlock |
|----------|---------|---------|---------------|
| `ACH_FIRST_ROOM` | Through the Door | 문을 넘어 | Enter your first room |
| `ACH_FIRST_CLUE` | First Discovery | 첫 번째 단서 | Find your first clue |
| `ACH_CLUE_10` | Curious Mind | 호기심 많은 탐정 | Discover 10 clues in one run |
| `ACH_ALL_CLUES` | Mansion Archivist | 저택 기록사 | Find all available clues in a single run |
| `ACH_DEEP_EXPLORE` | Deeper Halls | 더 깊은 복도로 | Reach the 5th room in a run |
| `ACH_FULL_MANSION` | Full Investigation | 완전한 조사 | Enter every room in a single run |
| `ACH_DANGER_ROOM` | Brave Investigator | 용감한 탐정 | Survive a high-danger room |
| `ACH_DANGER_CHAIN` | Risk Taker | 위험을 즐기는 자 | Survive 3 consecutive high-danger rooms |
| `ACH_SAFE_RUN` | Cautious Explorer | 신중한 탐험가 | Complete a run using only low-danger rooms |
| `ACH_SECOND_RUN` | Return to the Mansion | 저택으로의 귀환 | Complete a second investigation run |
| `ACH_DIFFERENT_PATH` | New Corridors | 새로운 복도 | Complete 2 runs with completely different room sequences |
| `ACH_MANSION_CLEAR` | Mystery Solved | 미스터리 해결 | Reach the mansion's final revelation |
| `ACH_SPEED_RUN` | Swift Investigator | 신속한 탐정 | Complete a run in under 15 minutes |
| `ACH_VETERAN` | Mansion Expert | 저택 전문가 | Complete 10 investigation runs |

---

## Implementation Notes

- Steam API: `ISteamUserStats`
- Room sequence tracking is needed for `ACH_DIFFERENT_PATH` (persist last-run room order, compare at run end)
- `ACH_SAFE_RUN` requires a danger-threshold tag per room; if any high-danger room is entered, flag fails for that run
- `ACH_ALL_CLUES` requires knowing total clue count per run seed/configuration
- Save data is managed by `SaveData` and `GameState` autoloads in Godot
- Steamworks GDNative/GDExtension plugin required for Godot 4 integration
- Replace App ID 480 with real Steamworks App ID before submission
