# ========== Die Spalte "date" wird erzeugt ==========

ankunftszeit <- function(trajdaten, zeit.intervall){
  # Hier werden jetzt die Zeiten berechnet zu denen die Luftpakete ankommen.
  # Z.b. habe ich 24 Trajektorien die 6 Stunden versetzt gestartet wurden
  # Es entsteht ein Vektor mit den Ankunftszeiten
  
  # Der Zeitpunkt zu dem die erste Trajektorie ankommt
  erste.ankunft <- trajdaten$date2[1]
  print("erste ankunft:")
  print(erste.ankunft)
  
  #!hier kann nicht ein fixes datum verwendet werden. Das Datum muss ausgelesen werden
  ankunft.zeit <- seq(
    from = as.POSIXct(erste.ankunft, tz = "UTC"), #from = as.POSIXct("2025-06-29 11:00:00", tz = "UTC"),
    by = zeit.intervall,
    length.out = length(unique(trajdaten$index)) # benutze ich das für irgendwas?
  )
  
  # Hier wird jetzt eine Tabelle erstellt in der die IDs mit den zugehörigen
  # Ankunftszeiten drin sind. Eine Spalte sind die IDs und die ander die Zeiten
  ankunft.lookup <- tibble(
    index = unique(trajdaten$index),
    date = ankunft.zeit
  )
  
  ankunft.lookup
  
  # left_join(x, y, by = "key")
  # Hier werden die Daten die in y sind und in der Key spalte 
  # den gleichen Wert haben, zu x hinzugefügt, in die korrespondierende 
  # Reihe
  
  traj.daten <- left_join(trajdaten, ankunft.lookup, by = "index")
  
  return(traj.daten)
}

# ========== Die Spalte "date2" wird ezeugt ==========

erzeugen.date2 <- function(traj.daten){
  # Hier wird jetzt date2 erzeugt
  # also die Zeitpunkte die zu den Endopoints gehören, nicht die Ankunftszeiten
  #date.merge1 <- apply(select(traj.daten, year, month, day), 1, paste, collapse = "-")
  
  traj.daten <- mutate(traj.daten, date2 = make_datetime(year = year + 2000, month = month, day = day, hour = hour))
  
  return(traj.daten)
}

# ========== eigene Funktion für die Änderung der "hour.inc" ==========

inc_change <- function(count, traj.daten) {
  
  # Es wird ein temporäres Tibble erzeugt, in dem nur einen Trajektorie ist
  temp_traj <- filter(traj.daten, index == count)
  
  # Die menge an Endpoints von der Trajektorie wird gespeichert
  len_traj <- length(unique(temp_traj$hour.inc))
  
  # Hier wird der Zeitstempel des ersten endpoint korigiert, sodass er dem Zeitpunkt der Ankunft entspricht
  temp_traj$date2[1] <- temp_traj$date[1]
  
  # Als erstes wird die Spalte "hour.inc" geändert
  # Der erste eintrag in "hour.inc" ist immer 0. Der zweite variiert für jede Trajektorie, soll aber -1 sein
  
  # es wird gespeichert, wie weit der zweite eintrag von -1 abweicht
  dif_inc <- abs(temp_traj$hour.inc[2]) - 1
  
  selector <- 2
  
  # Nun wird für jeden Endpoint "hour.inc" geändert
  while(selector <= len_traj) {
    
    # Der Eintrag in der gewählten Zeile wird addiert mit der Differenz die vorher festgestellt wurde
    temp_traj$hour.inc[selector] <- temp_traj$hour.inc[selector] + dif_inc
    
    selector <- selector + 1
  }
  
  return(temp_traj)
}

# ========== Tibble wird umstrukturiert ==========

struktur <- function(traj.daten){
  
  # Die Menge an Trajektorien, welche sich in dem Tibble befinden
  menge_traj <- length(unique(traj.daten$index))
  
  count <- 1
  
  # Zuerst muss ein Tibble erschaffen werden, an welches die anderen angehangen werden
  start_traj <- inc_change(count, traj.daten)
  
  count <- count + 1
  
  # Nun werden auch die anderen Trajektorien geändert und aneinander gehangen
  while (count <= menge_traj) {
    
    temp_traj <- inc_change(count, traj.daten)
    start_traj <- bind_rows(start_traj, temp_traj)
    
    count <- count + 1
  }
  
  return(start_traj)
  
}


# ========== Der Hauptloop ==========

traj_read <- function(traj.pfad, zeit.abstand) {
  
  #traj.pfad <- "../Hysplit/final-runs/" # Pfad zu Ordner in dem Output-Datein von Hysplit liegen
  #zeit.abstand <- "-1 hours" # Das Zeitintervall in dem Trajektorien gestartet wurden
  
  keyword = "PRESSURE"
  
  #Es wird eine Liste mit den Datein erstellt die Daten zu den Trajektorien enthalten
  files <- list.files(path = traj.pfad, pattern = "\\.txt$", full.names = TRUE)
  
  # Das löscht den oberen Teil der Datei, der nicht benötigt wird
  # es wird durch alle txt datein im ordner gegangen
  for (f in files) {
    inhalt <- read_lines(f)
    
    position <- grep(keyword, inhalt)
    print(position)
    
    if (length(position) > 0) {
      #alles was ab "PRESSURE" kommt wird erhalten
      inhalt <- inhalt[position:length(inhalt)]
      
      #Die Datei wird mit neuem Inhalt überschrieben
      write_lines(inhalt, f)
    }else {
      message("Fehler in:", f)
    }
  }
  
  files_check <- length(files)
  
  if(files_check == 0){
    cat("\n", "+++ If you are reading this no trajectory-files have been found. That probably means that the folder-path you passed to the function is wrong. Try fixing it.", "\n")
  }
  
  
  #print("Folder has been found!")
  
  # Hier ist definiert, an welcher Stelle eine Spalte anfängt und wo sie aufhört
  # Die erste Spalte beginnt z.B. bei 1 und hört auf bei 7. Die nächste beginnnt bei 8 und hört bei 13 auf usw.
  
  fwf_pos <- fwf_positions(
    start = c(1, 8, 14, 20, 26, 32, 38, 44, 50, 58, 67, 76, 85),
    end = c(7, 13, 19, 25, 31, 37, 43, 49, 57, 66, 75, 84, 93),
    col_names = c("index", "receptor", "year", "month", "day", "hour", "id", "id2", "hour.inc", "lat", "lon", "height", "pressure" )
  )
  
  
  x = 0
  
  
  
  for (f in files) {
    
    
    if(x == 0){
      trajdaten <- read_fwf(f, fwf_pos, skip = 1)
      print("traj read")
      
      # Die Zeitstempel für die Endpoints werden hinzugefügt
      trajdaten <- erzeugen.date2(trajdaten)
      
      # Die Ankunfszeit wird in das tibble eingefügt
      trajdaten <- ankunftszeit(trajdaten, zeit.abstand)
      
      trajdaten <- struktur(trajdaten)
      
    } else {
      #Es wird identifiziert wie viele Trajektorien bereits im tibble drin sind. Der höchster "Receptor" ist gleichzeitig die Anzahl der Trajektorien
      anzahl_traj <- max(trajdaten$index)
      temp_trajdaten <- read_fwf(f, fwf_pos, skip = 1)
      
      # Die Zeitstempel für die Endpoints werden hinzugefügt
      temp_trajdaten <- erzeugen.date2(temp_trajdaten)
      
      # Die Ankunfszeit wird in das tibble eingefügt
      temp_trajdaten <- ankunftszeit(temp_trajdaten, zeit.abstand)
      
      # Hier kann ich Funktion rufen, die hour.inc und date 2 umstrukturiert
      temp_trajdaten <- struktur(temp_trajdaten)
      
      #Die "receptor" bzw. eigentlich die id's werden plus den höchsten receptor aus dem haupt-tibble gerechnet. Dadurch werden die id's kontinuierlich und fangen nicht immer wieder bei 1 an
      temp_trajdaten <- mutate(temp_trajdaten, index = index + anzahl_traj)
      
      #Das temporäre tibble wird zu trajdaten hinzugefügt, mit koregierten id's
      trajdaten <- bind_rows(trajdaten, temp_trajdaten)
    }
    
    x = x + 1
  }
  
  # Die Koordinaten werden in einen sf-Point umgewandelt, damit diese mit anderen sf-Objekten genutzt werden können
  trajdaten <- mutate(trajdaten, geo = st_sfc(map2(lon, lat, ~st_point(c(.x, .y))), crs = 4326))
  
  
  return(trajdaten)
  
}


