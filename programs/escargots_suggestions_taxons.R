query <- "SELECT 
q.id as comment_id, 
user_id, 
model as comment_type, 
resource_id, 
resource_type,
q.created_at as date_comment,
json_value(`q`.`data`,
    '$.taxon') AS `taxon_brut`,
`t5`.`title` AS `taxon`,
json_value(`q`.`data`, '$.denominationPlusPreciseTruePrecision') as denomination_plus_precise
FROM `qubs`.`comments` q
left join `qubs`.`thesaurus_values` `t5` on
    (`t5`.`value` = json_value(`q`.`data`,'$.taxon'))"

suggestions <- import_from_mosaic(query,
                                  database_name = "qubs",
                                  force_UTF8 = TRUE)
unique(suggestions$resource_type)
unique(suggestions$comment_type)

# Récupérer les observations escargots pour lesquelles la dernière action est une suggestion en attente
suggestions <- suggestions %>% 
  filter(resource_type == "observation", comment_type %in% c("suggestion", "reidentification"),
         resource_id %in% unique(dt_escargots$observation_id)) %>%
  group_by(resource_id) %>% 
  mutate(ordre_action = c(1:n())) %>%
  filter(ordre_action == max(ordre_action)) %>%
  filter(comment_type == "suggestion") %>%
  rename(observation_id = resource_id,
         taxon_suggestion = taxon,
         denom_plus_precise_suggestion = denomination_plus_precise)

# Faire une jointure pour intégrer les suggestions de taxon et de denomination_plus précise dans l'export escargots
dt_escargots <- dt_escargots %>% left_join(suggestions %>% 
                                     select(observation_id, 
                                            taxon_suggestion, 
                                            denom_plus_precise_suggestion),
                                   by = "observation_id")

# Remplacer la valeur taxon par la suggestion ou la catégorie (Limace ou Escargot) quand les conditions sont remplies
dt_escargots <- dt_escargots %>% group_by(observation_id) %>% 
  mutate(taxon_correction = ifelse(taxon_valide == 1,
                                   #si le taxon est validé mais NA alors remplacer par la categorie
                                   ifelse(is.na(taxon), categorie_taxon, taxon),
                                   ifelse(is.na(taxon),
                                          #si le taxon n'est pas validé, est NA et la suggestion est NA alors mettre la categorie,
                                          #sinon remplacer par la catégorie
                                          ifelse(!is.na(taxon_suggestion), taxon_suggestion, categorie_taxon),
                                          #si le taxon n'est pas validé, 
                                          #n'est pas NA, et la valeur est différente de la suggestion alors mettre la suggestion
                                          #sinon conserver la valeur initiale
                                          ifelse(taxon != taxon_suggestion, taxon_suggestion, taxon))))

readr::write_excel_csv2(dt_escargots, "export_escargots_suggestions.csv")
