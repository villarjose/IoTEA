#references:
# R and MySQL:
#    https://www.r-bloggers.com/accessing-mysql-through-r/
#    https://www.r-bloggers.com/connecting-r-to-mysqlmariadb/
#    https://cran.r-project.org/web/packages/RMySQL/



#createtable(profile, idprofile:<int,PK>, label:<text50,REQUIRED>)
#insert
# 0, Not considered -all the profiles are included-
# 1, Healthy
# 2, Walking stick, crutch or crutches, etc
# 3, Cognitive impairment

#createtable(activity, idactivity:<int,PK>, label:<text50,REQUIRED>, isa:<int,can be empty>)
#insert:
# 1.0.0, Resting
#   1.1.0, Lying, 1.0.0
#     1.1.1, Sleeping, 1.1.0
#     1.1.2, Resting, 1.1.0
#   1.2.0, Sitting, 1.0.0
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

#createtable(similar_activities, < idact1:<int,FK>, idact2<int,FK>, idprofile:<int,FK> >:<PK>)
#insert
# to be determined after visualization of the data


#createtable(sliding_window, < idact1:<int,FK>, idprofile:<int,FK>, idparticipant:<int,FK,might be empty>:<PK>, windowsize:<int, positive>, shift:<int, positive>)


# Para el caso de usar un profile concreto...
#   (ojo: para el caso de main_profile 0, buscar las actividades similares se complica...)
#   (ojo: esto es entrenamiento, por eso se recopilan todos los datos y se calculan las  
#         transformadas. En explotacion esto puede ser diferente)
# Parameters:
#   main_act <- activity to learn
#   main_profile <- main characteristic profile of the participant
#   participant <- id del participante, < 0 si es para toda la poblacion
#   comparar_actividades=0 <- 1 si se desea rellenar la tabla similar_activities, 0 en caso contrario
#   
# Acciones:
#   window <- obtener datos de ventana para main_act, main_profile, participant
#   if comparar_actividades==1
#       analizar_compatibilidades(main_act, main_profile, participant, window)
#   P_data <- empty data.frame
#   nd <- recopilar datos actividad main_act
#   tramos <- segmentar nd por tramos no consecutivos en el tiempo
#   For each tramo in tramos
#     P_data <- agnadir tramo como una nueva TS a P_data  
#   sim_acts <- actividades similares a main_profile segun indicado en similar_activities
#   N_data <- empty data.frame
#   For each act in sim_acts:
#     nd <- recopilar datos act
#     tramos <- segmentar nd por tramos no consecutivos en el tiempo
#     For each tramo in tramos
#        N_data <- agnadir tramo como una nueva TS a N_data  
#   dif_acts <- actividades que no son similares a main_profile (son acts que no 
#           aparecen en similar_activities para main_profile)
#   F_data <- empty data.frame
#   For each act in dif_acts:
#     nd <- recopilar datos act
#     tramos <- segmentar nd por tramos no consecutivos en el tiempo
#     For each tramo in tramos
#        F_data <- agnadir tramo como una nueva TS a F_data  
#   pos_data <- Calcular transformadas a P_data 
#        (ojo: se aplica la ventana deslizante sobre cada tramo, generando una muestra de 
#            transformada por cada ventana: se reduce el numero de muestras)
#   neg_data <- Calcular transformadas a N_data 
#   dif_data <- Calcular transformadas a F_data
#   pos_data_train <- 90% de los datos de pos_data
#   pos_data_test <-  10% de los datos de pos_data
#   neg_data_train, neg_data_test <- completar_balanceado(pos_data_train, neg_data, dif_data)
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

HARgetAllActivities <- function(conn, level=-1) {
  res <- dbSendQuery(conn, "select idactivity, label from activity")
  ans <- data.frame()
}


ModelLearningInterface <- function() {
  conn <- dbConnect(MySQL(), user='user', password='password', dbname='database_name', host='host')
  activs<- HARgetAllActivities(conn)  
  
  
  dbDisconnect(conn)
}



