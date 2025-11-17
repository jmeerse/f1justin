install.packages("f1dataR")
library(f1dataR)
library(tidyverse)

py_require("pip")
#load_drivers(2025)
clear_cache()



laps2025 <- load_laps(season = 2025) #doesn't work


load_laps(season = "current", round = "last") #doesn't work


ham <- load_driver_telemetry(season = "current", session = "R",driver = "HAM", laps = "all")

laps_2025 <- data.frame()
for (i in 1:20) {

  df <- load_session_laps(season = "current",
                               round = i,
                               session = "R", 
                               add_weather = T)
  laps_2025 <- rbind(laps_2025, df)
}

laps_2025 <- laps_2025 %>% mutate(race_date = substr(lap_start_date, 1, 10))
laps_2025 <- laps_2025 %>% mutate(race_date = as.Date(race_date))

laps_2025 %>% count(race_date) %>% print(n = 21) #need to get race 21

ave_by_race <- laps_2025 %>% 
  filter(compound != "nan" , compound != "None") %>% 
  group_by(race_date, compound) %>% 
  summarise(mean_lap = mean(lap_time, na.rm = T),
            n = n()) %>% ungroup()

ave_by_race %>% ggplot(aes(x = race_date, y = mean_lap, color = compound)) + geom_point()

ave_by_driver <- laps_2025 %>% 
  group_by(race_date, driver, compound) %>% 
  summarise(mean_lap = mean(lap_time, na.rm = T),
            n = n()) %>% 
  ungroup()

ave_by_driver %>% ggplot(aes(x = race_date, y = mean_lap, colour = driver)) +
  geom_line() + facet_wrap(~compound)


laps_2025 %>% filter(compound != "nan", compound != "None", !is.na(lap_time)) %>%  
  ggplot(aes(x = lap_number, y = lap_time, 
             group = driver, color = compound)) + 
  geom_line() +
  theme_bw() +
  facet_wrap(~race_date)
