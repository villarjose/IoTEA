#references:
# Matrices and Factors:
#    https://www.programiz.com/r-programming/data-frame
#    https://www.programiz.com/r-programming/factor
# R and MySQL:
#    https://www.r-bloggers.com/accessing-mysql-through-r/
#    https://www.r-bloggers.com/connecting-r-to-mysqlmariadb/
#    https://cran.r-project.org/web/packages/RMySQL/
#    para bigint!!!
#    https://stackoverflow.com/questions/3241748/using-rmysqls-dbgetquery-in-r-how-do-i-coerce-string-data-type-on-the-result-s
#    https://stackoverflow.com/questions/7105962/how-do-i-run-a-high-pass-or-low-pass-filter-on-data-points-in-r
#SVM:
#    https://cran.r-project.org/web/packages/e1071/vignettes/svmdoc.pdf
#    https://www.svm-tutorial.com/2014/10/support-vector-regression-r/
#    https://eight2late.wordpress.com/2017/02/07/a-gentle-introduction-to-support-vector-machines-using-r/
#    https://www.r-bloggers.com/learning-kernels-svm/


#createtable(profile, idprofile:<int,PK>, label:<text50,REQUIRED>)
#insert
# 0, Not considered -all the profiles are included-
# 1, Healthy
# 2, Walking stick, crutch or crutches, etc
# 3, Cognitive impairment

#createtable(activity, idactivity:<text11,PK>, label:<text50,REQUIRED>, 
#            isa:<int,can be empty>)
#  11 viene de tres dígitos para cada nivel + dos puntos.
#insert:
# 1.0.0, Resting
#   1.1.0, Lying, 1.0.0
#     1.1.1, Sleeping, 1.1.0
#     1.1.2, Resting, 1.1.0
#   1.2.0, Sitting, 1.0.0
#     1.2.1, Sleeping, 1.3.0
#     1.3.2, Resting, 1.3.0
# 2.0.0, Transition
#   2.1.0, Getting up, 2.0.0
#     2.1.1, Uprise from a bed, 2.1.0
#     2.1.2, Uprise from a chair, 2.1.0
#   2.2.0, Lying down, 2.0.0
#     2.2.1, Lying down on a bed, 2.2.0
#     2.2.2, Sitting down on a chair, 2.2.0
# 3.0.0, Walk
#   3.1.0, Without assistance, 3.0.0
#     3.1.1, Walk, 3.1.0
#     3.1.2, Stairs up, 3.1.0
#     3.1.3, Going down a ramp, 3.1.0
#   3.2.0, With the assistance of a rail, 3.0.0
#     3.2.1, Walk, 3.1.0
#     3.2.2, Stairs up, 3.1.0
#     3.2.3, Going down a ramp, 3.1.0

#createtable(activity_distances, < idact1:<int,FK>, idact2<int,FK>, idprofile:<int,FK>, 
#                                  idparticipant:<int,FK>>:<PK>, q25:<float>,
#                                 q50:<float>, q75:<float>)
#the similarities between two activities might not be simmetrical
#idact1 is the activity to compare with idact2



#createtable(sliding_window, < idact1:<int,FK>, idprofile:<int,FK>, 
#                              idparticipant:<int,FK,might be empty>:<PK>, 
#                              windowsize:<int, positive>, shift:<int, positive>)





# Para el caso de usar un profile concreto...
#   (ojo: para el caso de main_profile 0, buscar las actividades similares se complica...)
#   (ojo: esto es entrenamiento, por eso se recopilan todos los datos y se calculan las  
#         transformadas. En explotacion esto puede ser diferente)
# Parameters:
#   main_act <- activity to learn
#   main_profile <- main characteristic profile of the participant
#   participant <- id del participante, < 0 si es para toda la poblacion
#   
# Acciones:
#   window <- obtener datos de ventana para main_act, main_profile, participant
#   distances <- HARgetActivitySimilarities(connect, main_act, main_profile, participant)
#
#   P_data <- empty data.frame
#   nd <- recopilar datos actividad main_act
#   tramos <- segmentar nd por tramos no consecutivos en el tiempo
#   For each tramo in tramos
#     P_data <- agnadir tramo como una nueva TS a P_data  
#   sim_acts <- actividades similares a main_profile segun indicado en similar_activities
#
#   N_data <- empty data.frame
#   For each act in sim_acts:
#     nd <- recopilar datos act
#     tramos <- segmentar nd por tramos no consecutivos en el tiempo
#     For each tramo in tramos
#        N_data <- agnadir tramo como una nueva TS a N_data  
#   dif_acts <- actividades que no son similares a main_profile (son acts que no 
#           aparecen en similar_activities para main_profile)
#
#   F_data <- empty data.frame
#   For each act in dif_acts:
#     nd <- recopilar datos act
#     tramos <- segmentar nd por tramos no consecutivos en el tiempo
#     For each tramo in tramos
#        F_data <- agnadir tramo como una nueva TS a F_data  
#
#   pos_data <- Calcular transformadas a P_data 
#        (ojo: se aplica la ventana deslizante sobre cada tramo, generando una muestra de 
#            transformada por cada ventana: se reduce el numero de muestras)
#   neg_data <- Calcular transformadas a N_data 
#   dif_data <- Calcular transformadas a F_data
#
#   pos_data_train <- 90% de los datos de pos_data
#   pos_data_test <-  10% de los datos de pos_data
#   neg_data_train, neg_data_test <- completar_balanceado(pos_data_train, neg_data, dif_data)
#
#   Mu, sigma <- estadisticas de pos_data_train
#   pos_data_train <- normalizar pos_data_train con Mu, sigma
#   pos_data_test <- normalizar pos_data_test con Mu, sigma
#   neg_data_train <- normalizar neg_data_train con Mu, sigma
#   neg_data_test <- normalizar neg_data_test con Mu, sigma
#   svm_mod, svm_stats <- generar_svm(pos_data_train, pos_data_tst, neg_data_train, neg_data_test)
#   knn_mod, knn_stats <- generar_knn(pos_data_train, pos_data_tst, neg_data_train, neg_data_test)
#   dt_mod, dt_stats <- generar_dt(pos_data_train, pos_data_tst, neg_data_train, neg_data_test)
#   ensemble1 <- weighted_average(svm_mod, knn_mod, dt_mod, pos_data_tst, neg_data_tst)
#   aprender svm con ventana deslizante sobre salida de ensemble1


library(RMySQL)
library(signal)



HARgetAllActivities <- function(connect, level=3) {
  if (level < 0) { 
    sqlstm <- "select idactivity, label from activity; " 
  }
  else if (level == 0) { 
    sqlstm <- "select idactivity, label from activity; " 
  }
  else if (level == 1) { 
    sqlstm <- "select idactivity, label from activity where idactivity LIKE '[1-9][0-9]%.0.0'; "
  }
  else if (level == 2) {
    sqlstm <- "select idactivity, label from activity where idactivity LIKE '[0-9]%.[1-9][0-9]%.0'; "
  }
  else if (level == 3) {
    sqlstm <- "select idactivity, label from activity where idactivity LIKE '[0-9]%.[0-9]%.[1-9][0-9]%'; "
  }
  res <- dbGetQuery(connect, sqlstm)
}

#tmp <- sprintf("SELECT * FROM emp WHERE lname = %s", "O'Reilly")
#dbEscapeStrings(con, tmp)
#sql <- sprintf("insert into networks
#                  (species_id, name, data_source, description, created_at)
#               values (%d, '%s', '%s', '%s', NOW());",
#               species.id, network.name, data.source, description)
#rs <- dbSendQuery(con, sql)
#dbClearResult(rs)



#------------------------------------------------------------------------------
# HARcomputeActivitySimilarities
#------------------------------------------------------------------------------
#Input:
#   connect       acceso a la base de datos
#   idactivity    actividad para la que se almacenan las similitudes
#   idprofile     profile para la que se almacena, -1 si no se indica
#   idparticipant sujeto para la que se almacena, -1 si no se indica
#Output:
#   una matriz de similitudes, pares <idactivity, <q25, q50, q75> >
#
HARcomputeActivitySimilarities <- function(connect, idactivity, idprofile=-1, idparticipant=-1 ) {
  sqlstm <- paste('select * from ACC_DATA where idactivity =', idactivity)
  if (profile != -1) {
    sqlstm <- paste(sqlstm, 'and', 'idprofile =', toString(idprofile))
  }
  if (idparticipant != -1) {
    sqlstm <- paste(sqlstm, 'and', 'idparticipant =', toString(idparticipant))
  }
  sqlstm <- paste(sqlstm, ";")
  actdata <- dbGetQuery(connect, sqlstm)
  ns <- nrow(actdata)
  
  acts <- HARgetAllActivities(connect, 3)
  acts <- acts[, 'idactivity']
  acts <- acts[acts!=idactivity]
  
  sims <- data.frame()
  for( idact in acts) {
    eudist <- data.frame()
    sqlstm <- paste('select * from ACC_DATA where idactivity =', idact, ";")
    idactdata <- dbGetQuery(connect, sqlstm)
    whole <- rbind(actdata,idactdata)
    dm <- as.matrix(dist(whole, method = 'euclidean'))
    l = nrow(dm)
    dm <- dm[(ns+1):l, 1:ns]
    sims <- rbind(sims, quantile(matrix(dm,nrow=1))[2:4])
  }
  rownames(sims) <- acts
  colnames(sims) <- c("q25", "q50", "q75")
  return(sims)
}


#------------------------------------------------------------------------------
# HARsetActivitySimilarities
#------------------------------------------------------------------------------
#Esta función actualiza en la base de datos las similitudes de una actividad 
#con el resto de actividades del mismo contexto (idprofile, idparticipant)
#Input:
#   connect       acceso a la base de datos
#   idactivity    actividad para la que se almacenan las similitudes
#   idprofile     profile para la que se almacena, -1 si no se indica
#   idparticipant sujeto para la que se almacena, -1 si no se indica
#   sims          matriz de similitudes. Si NULL no se hace nada.
#
HARsetActivitySimilarities <- function(connect, idactivity, idprofile = -1, idparticipant = -1, 
                           sims = NULL) {
  if (is.null(sims)) {
    return(-1)
  }
  basesql <- paste("insert into activity_distances",
                  "(idact1, idact2, idprofile, idparticipant, q25, q50, q75)",
                  "values (%d, %d, %d, %d, %f, %f, %f);" )
  rns <- rownames(sims)
  for( r in rns) {
    sqlstm <- sprintf(basesql, idactivity, r, idprofile, idparticipant, 
                      sims[r,1], sims[r,2], sims[r,3])
    res <- dbGetQuery(sqlstm)
  }
  return(0)
}

#------------------------------------------------------------------------------
# HARgetActivitySimilarities
#------------------------------------------------------------------------------
#Esta funcion usa la base de datos y recupar las actividades similares a la 
#actual en el mismo contexto (profile y participante, si estan dados).
#Input:
#  connect     conexion a la base de datos
#  idactivity  actividad para la que se recuperan las actividades similares
#  idprofile   profile para el que se buscan las actividades similares, -1 si no
#              se desea especificar este valor
#  idparticipant   sujeto para el que se buscan las actividades similares, -1 si 
#              no se desea especificar este valor
#Output:
#  ans     listado de actividades similares, con idactivity, y los 3 cuartiles.
#
HARgetActivitySimilarities <- function(connect, idactivity, idprofile = -1, idparticipant = -1) {
  sqlstm <- paste('select idact2, q25, q50, q75 from activity_distances where idactivity =', idactivity)
  if (profile != -1) {
    sqlstm <- paste(sqlstm, 'and', 'idprofile =', toString(idprofile))
  }
  if (idparticipant != -1) {
    sqlstm <- paste(sqlstm, 'and', 'idparticipant =', toString(idparticipant))
  }
  sqlstm <- paste(sqlstm, ';')
  actdata <- dbGetQuery(connect, sqlstm)
  if (nrow(actdata) == 0) {
    ans <- HARcomputeActivitySimilarities(connect, idactivity, idprofile, idparticipant)
    return(ans)
  }
  else {
    nms <- actdata[,1]
    ans <- actdata[,2:4]
    rownames(ans) <- nms
    colnames(ans) <- c("q25", "q50", "q75")
    return(ans)
  }
}



#------------------------------------------------------------------------------
# HARsplitIntoTS
#------------------------------------------------------------------------------
#This function receives a dataframe with timestamps and the raw data (3DACC+HR),
#and generates a list of TS, spliting them when there are big differences in the
#timestamps
#Input:
#   df       the dataframe with all the data
#Output:
#   ans      a list with dataframes, one per TS
#
HARsplitIntoTS <- function(df) {
  timedif <- df[3:nrow(df), 1] - df[2:(nrow(df)-1), 1] > 
                1.2 * df[2:(nrow(df)-1), 1] - df[1:(nrow(df)-2), 1]
  positions <- which(timedif %in% TRUE)
  p = 1
  nTS <- list()
  p1 = 1
  while (p <= length(positions)){
    nTS[[p]] <- df[p1:positions[p],]
    p1 <- positions[p]
    p <- p + 1
  }
  return(nTS)
}


#------------------------------------------------------------------------------
# HARrequestAllACCHRData
#------------------------------------------------------------------------------
#This function returns a dataframe with all the data for a pair <participant, 
#activity> from the database
#Input:
#  connect     conexion a la base de datos
#  idactivity  actividad para la que se recuperan las actividades similares
#  idparticipant   sujeto para el que se buscan las actividades similares, -1 si 
#              no se desea especificar este valor
#Output:
#  df          dataframe con los datos pedidos
#
HARrequestAllACCHRData <- function(connect, idparticipant, idactivity="0.0.0") {
  if (idactivity == "0.0.0") {
    sqlstm <- paste("select * from ACC_HR where id = ", idparticipant,sep='')
    df <- dbGetQuery(sqlstm)
  }
  else {
    sqlstm <- paste("select * from ACC_HR where id = ", idparticipant,
                    " and Actividad=",idactivity,sep='')
    df <- dbGetQuery(sqlstm)
  }
  return(df)
}



#------------------------------------------------------------------------------
# HARcomputeSMA(df, ws, shift)
#------------------------------------------------------------------------------
#Esta funcion calcula SMA de un data.frame con accx,accy,accz. A sliding window 
#is performed on the data.
#Input:
#  d      vector de tres coordanadas x,y,z
#  ws     the sliding window size
#  shift  the shift used for the sliding window
#Output:
#  SMA calculado
#
sma <- function(d) {
  if (nrow(d) == 0) { return(0) }
  r <- sum(abs(d)) / nrow(d)
  return(r)
}

HARcomputeSMA <- function(df, ws, shift){
  b <- seq(ws, nrow(df), shift)
  a <- seq(1, nrow(df) -shift, shift)
  a <- a[1:nrow(b)]
  r <- apply(data.frame(a, b), MARGIN=1,
        function(x) sma(df[x[1]:x[2],]))
  return(r)
}


#------------------------------------------------------------------------------
# HARcomputeAoM(df, ws, shift)
#------------------------------------------------------------------------------
#Esta funcion calcula AoM de un vector con accx,accy,accz. A sliding window 
#is performed on the data.
#Input:
#  d      vector de tres coordanadas x,y,z
#  ws     the sliding window size
#  shift  the shift used for the sliding window
#Output:
#  AoM calculado
#
aom <- function(d) {
  D <- abs(d)
  r <- sum(apply(d, 1, max) - apply(d, 1, min))
  return(r)
}
HARcomputeAoM <- function(df, ws, shift) {
  b <- seq(ws, nrow(df), shift)
  a <- seq(1, nrow(df) -shift, shift)
  a <- a[1:nrow(b)]
  r <- apply(data.frame(a, b), MARGIN=1,
        function(x) aom(df[x[1]:x[2],]))
  return(r)
}


#------------------------------------------------------------------------------
# HARcomputeTBP(df, ws, shift, K)
#------------------------------------------------------------------------------
#Esta funcion calcula Time between Peaks de un vector con accx,accy,accz. A 
#sliding window is performed on the data.
#Input:
#  d      vector de tres coordanadas x,y,z
#  ws     the sliding window size
#  shift  the shift used for the sliding window
#  K      the deviation multiplier to detect the peak, default value is 0.9
#Output:
#  TBP calculado
#
tbp <- function(d, K=0.9){
  a <- apply(data.frame(apply(d^2,1,sum)),1,sqrt) #modulo de los 3 ejes
  b <- c(a > (mean(a) + K * sd(a)))
  e <- c(0, diff(b,1) > 0) #el primer 0 es porque diff tiene una dimension menos
  #                         que b.
  f <- c(0, which(c(0,diff(c,1)>0) %in% 1)) #idem de lo mismo
  g <- mean(diff(f))
  return(g)
}

HARcomputeTBP <- function(df, ws, shift, K=0.9) {
  b <- seq(ws, nrow(df), shift)
  a <- seq(1, nrow(df) -shift, shift)
  a <- a[1:nrow(b)]
  r <- apply(data.frame(a, b), MARGIN=1,
             function(x) tbp(df[x[1]:x[2],], K))
  return(r)
}



#------------------------------------------------------------------------------
# HARcreateEllipFilter(n, Rs, Rp, W, type='high', plane='z')
#------------------------------------------------------------------------------
#Esta funcion calcula un filtro usando el paquete signal, función ellip.
#Input:
#  n, Rs, Rp, W      see signal::ellip for info
#  type              'high', 'low', ...  see signal::ellip for info
#  plane             'z', 's'            see signal::ellip for info
#Output:
#  filt   filtro calculado
#
HARcreateEllipFilter <- function(n, Rs, Rp, W, type='high', plane='z') {
  a <- ellip(n, Rs, Rp, W, type, plane)
  return(a)
}

#------------------------------------------------------------------------------
# HARapplyEllipFilter(filt, ts)
#------------------------------------------------------------------------------
#Usando el filtro dado, se aplica el filtro. Utiliza signal::filter. Se aplica
#sobre vectores o, bien, sobre series temporales del paquete signal.
#Tras pruebas con valroes de init, no se ha obtenido el comportamiento esperado.
#Pendiente de mejora.
#Input:
#  filt       filtro calculado con HARcreateEllipFilter
#  ts         vector o serie temporal a lo que se le aplica el filtro
#Output:
#  y          salida filtrada
#
HARapplyEllipFilter <- function(filt, ts){
  x <- as.vector(ts)
  #if (is.list(filt)) {  initSize <- length(filt$b) -1 }
  #else { initSize <- length(filt) }
  y <- as.vector(signal::filter(filt, x) )  #, init=initState))
  return(y)
}



#------------------------------------------------------------------------------
# HARcreateHighPassEllipFilter()
#------------------------------------------------------------------------------
#Crea el filtro especifico utilizado en toda la investigacion previa para 
#filtrar ACC y extraer la BA. Es un filtro paso alto.
#Llama a la funcion HARcreateEllipFilter
#Input:
#Output:
#  f          filtro de paso alto obtenido
#
HARcreateHighPassEllipFilter <- function() {
  return(HARcreateEllipFilter(8, 3, 3.5, 0.25, 'high'))
}

#------------------------------------------------------------------------------
# HARcreateLowPassEllipFilter()
#------------------------------------------------------------------------------
#Crea el filtro especifico utilizado en toda la investigacion previa para 
#filtrar ACC y extraer la G. Es un filtro paso bajo.
#Llama a la funcion HARcreateEllipFilter
#Input:
#Output:
#  f          filtro e paso bajo obtenido
#
HARcreateLowPassEllipFilter <- function() {
  return(HARcreateEllipFilter(3, 0.1, 100, 0.3, 'low'))
}



#------------------------------------------------------------------------------
# HARextractBAfromACC(acc)
#------------------------------------------------------------------------------
#Obtiene las componentes de la aceleracion del cuerpo BA a partir de las 
#medidas generadas por un acelerometro.
#Crea un filtro de paso alto usando HARcreateHighPassEllipFilter y la aplica 
#para cada VECTOR COLUMNA a la funcion HARapplyEllipFilter. El resultado es una
#matriz conteniendo las tres componentes de la BA
#Input:
# acc        matriz o data.frame con tres columnas, una para cada eje.
#Output:
#  y         segnal filtrada para cada eje, con tres columnas.
#
HARextractBAfromACC <- function(acc) {
  filt <- HARcreateHighPassEllipFilter()
  salida <- apply(data.frame(1:3), MARGIN=1, function(x) HARapplyEllipFilter(filt,ACC[,x]))
  return(salida)
}


#------------------------------------------------------------------------------
# HARextractGfromACC(acc)
#------------------------------------------------------------------------------
#Obtiene las componentes de la aceleracion de la gravedad G a partir de las 
#medidas generadas por un acelerometro.
#Crea un filtro de paso alto usando HARcreateLowPassEllipFilter y la aplica 
#para cada VECTOR COLUMNA a la funcion HARapplyEllipFilter. El resultado es una
#matriz conteniendo las tres componentes de la G
#Input:
# acc        matriz o data.frame con tres columnas, una para cada eje.
#Output:
#  y         segnal filtrada para cada eje, con tres columnas.
#
HARextractGfromACC <- function(acc) {
  filt <- HARcreateLowPassEllipFilter()
  salida <- apply(data.frame(1:3), MARGIN=1, function(x) HARapplyEllipFilter(filt,ACC[,x]))
  return(salida)
}



#------------------------------------------------------------------------------
# setNaN(v, mu)
#------------------------------------------------------------------------------
#Ajusta los valores NaN en v al valor dado mu
#Input:
# v        vector a elimiar los NaN
# mu       valor que sustituye al NaN
#Output:
#  v       vector sin NaN
#
setNaN <- function(v, mu) {
  v[is.nan(v)] <- mu
  return(v)
}

#------------------------------------------------------------------------------
# HARextractGfromACC(acc)
#------------------------------------------------------------------------------
#Obtiene las componentes de la aceleracion de la gravedad G a partir de las 
#medidas generadas por un acelerometro.
#Crea un filtro de paso alto usando HARcreateLowPassEllipFilter y la aplica 
#para cada VECTOR COLUMNA a la funcion HARapplyEllipFilter. El resultado es una
#matriz conteniendo las tres componentes de la G
#Input:
# acc        matriz o data.frame con tres columnas, una para cada eje.
#Output:
#  y         segnal filtrada para cada eje, con tres columnas.
#
HARnormalize <- function(ts, mu=NULL, sig=NULL) {
  if (is.null(mu)){
    mu <- colMeans(ts)
  }
  if (is.null(sig)) {
    sig <- apply(data.frame(1:3), MARGIN=1, function(i) sd(ts[,i]))
  }
  salida <- sweep(sweep(ts, 2, mu, FUN='-'), 2, FUN='/')
  salida <- apply(data.frame(1:ncol(salida)), MARGIN = 1, function(i) setNaN(salida[,i], mu[i]))
}




ModelLearningInterface <- function() {
  connect <- dbConnect(MySQL(), user='essy', password='Papatolati666', 
                       dbname='ESSYDB', host='156.35.22.10')
  activs<- HARgetAllActivities(connect)  
  
  
  dbDisconnect(conn)
}





