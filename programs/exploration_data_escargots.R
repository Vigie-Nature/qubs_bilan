test <- dt_escargots %>% group_by(abri_id) %>% mutate(nb_sessions = n_distinct(participation_id)) %>% filter(nb_sessions > 1)

dates_parti <- test %>% group_by(participation_id) %>% mutate(diversite = n_distinct(taxon)) 

dates_parti$diversite[dates_parti$presence_organisme == 0] <- 0
  
dates_parti %>% select(participation_id, abri_id, abri_typ, diversite, date) %>% distinct() %>% mutate(date = as.Date(date))
max(dates_parti$diversite)

dates_parti %>% 
  ggplot(aes(x = diversite, fill = abri_typ)) + 
  geom_bar(position = position_dodge(preserve = "single"))


dates_parti %>% group_by(abri_typ, diversite) %>%
  reframe(nb_sessions = n_distinct(participation_id)) %>%
  tidyr::complete(abri_typ, diversite) %>%
  ggplot(aes(x = diversite, y = nb_sessions, fill = abri_typ)) +
           geom_bar(stat = "identity", position = "dodge")

         