CREATE DATABASE educacion;
USE educacion;

-- 1. Tabla de géneros
CREATE TABLE generos (
    genero_id INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(20) UNIQUE NOT NULL
);

-- 2. Tabla de estados de matrícula
CREATE TABLE estados_matricula (
    estado_id INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(30) UNIQUE NOT NULL
);

-- 3. REPRESENTANTES
CREATE TABLE representantes (
    representante_id INT AUTO_INCREMENT PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    telefono VARCHAR(15) NOT NULL CHECK (telefono REGEXP '^[0-9]{10}$'),
    correo VARCHAR(100) NOT NULL UNIQUE
);

-- 4. ESTUDIANTES
CREATE TABLE estudiantes (
    estudiante_id INT AUTO_INCREMENT PRIMARY KEY,
    cedula VARCHAR(10) UNIQUE NOT NULL CHECK (cedula REGEXP '^[0-9]{10}$'),
    genero_id INT,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    direccion TEXT NOT NULL,
    telefono VARCHAR(15) CHECK (telefono REGEXP '^[0-9]{10}$'),
    correo VARCHAR(100) UNIQUE,
    representante_id INT,
    FOREIGN KEY (genero_id) REFERENCES generos(genero_id),
    FOREIGN KEY (representante_id) REFERENCES representantes(representante_id)
);

-- 5. DOCENTES
CREATE TABLE docentes (
    docente_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    titulo_obtenido VARCHAR(200) NOT NULL,
    telefono VARCHAR(15) CHECK (telefono REGEXP '^[0-9]{10}$'),
    correo VARCHAR(100) UNIQUE
);

-- 6. MATERIAS
CREATE TABLE materias (
    materia_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    horas_semanales INT NOT NULL CHECK (horas_semanales > 0)
);

-- 7. PARALELOS
CREATE TABLE paralelos (
    paralelo_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_paralelo VARCHAR(10) NOT NULL,
    grado VARCHAR(10) NOT NULL CHECK (grado IN ('Primero', 'Segundo', 'Tercero', 'Cuarto', 'Quinto', 'Sexto','Séptimo')),
    cupo_maximo INT CHECK (cupo_maximo > 0)
);

-- 8. HORARIOS
CREATE TABLE horarios (
    horario_id INT AUTO_INCREMENT PRIMARY KEY,
    dia VARCHAR(20) NOT NULL CHECK (dia IN ('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes')),
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    CHECK (hora_inicio < hora_fin)
);

-- 9. ASIGNACION DE MATERIAS
CREATE TABLE asignacion_materias (
    asignacion_id INT AUTO_INCREMENT PRIMARY KEY,
    materia_id INT NOT NULL,
    docente_id INT, 
    paralelo_id INT NOT NULL,
    horario_id INT NOT NULL,
    FOREIGN KEY (materia_id) REFERENCES materias(materia_id) ON DELETE CASCADE,
    FOREIGN KEY (docente_id) REFERENCES docentes(docente_id) ON DELETE SET NULL,
    FOREIGN KEY (paralelo_id) REFERENCES paralelos(paralelo_id) ON DELETE CASCADE,
    FOREIGN KEY (horario_id) REFERENCES horarios(horario_id) ON DELETE CASCADE
);

-- 10. MATRICULAS
CREATE TABLE matriculas (
    matricula_id INT AUTO_INCREMENT PRIMARY KEY,
    estudiante_id INT NOT NULL,
    paralelo_id INT NOT NULL,
    fecha_matricula DATE NOT NULL,
    estado_id INT NOT NULL,
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(estudiante_id) ON DELETE CASCADE,
    FOREIGN KEY (paralelo_id) REFERENCES paralelos(paralelo_id) ON DELETE CASCADE,
    FOREIGN KEY (estado_id) REFERENCES estados_matricula(estado_id)
);

-- 11. CALIFICACIONES
CREATE TABLE calificaciones (
    calificacion_id INT AUTO_INCREMENT PRIMARY KEY,
    estudiante_id INT NOT NULL,
    asignacion_id INT NOT NULL,
    trimestre INT NOT NULL CHECK (trimestre BETWEEN 1 AND 3),
    nota DECIMAL(5,2) NOT NULL CHECK (nota BETWEEN 0 AND 10),
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(estudiante_id) ON DELETE CASCADE,
    FOREIGN KEY (asignacion_id) REFERENCES asignacion_materias(asignacion_id) ON DELETE CASCADE
);

-- 12. ASISTENCIAS
CREATE TABLE asistencias (
    asistencia_id INT AUTO_INCREMENT PRIMARY KEY,
    estudiante_id INT NOT NULL,
    asignacion_id INT NOT NULL,
    fecha_asistencia DATE NOT NULL,
    presente BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(estudiante_id) ON DELETE CASCADE,
    FOREIGN KEY (asignacion_id) REFERENCES asignacion_materias(asignacion_id) ON DELETE CASCADE
);





-- CREACIÓN DE ROLES

CREATE ROLE administrador;
CREATE ROLE secretaria;
CREATE ROLE docente;
CREATE ROLE representante;
CREATE ROLE auditor;

-- ADMINISTRADOR
GRANT ALL PRIVILEGES ON educacion.* TO administrador;

-- SECRETARÍA
GRANT SELECT, INSERT, UPDATE ON educacion.estudiantes TO secretaria;
GRANT SELECT, INSERT, UPDATE ON educacion.matriculas TO secretaria;
GRANT SELECT, INSERT, UPDATE ON educacion.asignacion_materias TO secretaria;

-- DOCENTE
GRANT SELECT, INSERT, UPDATE ON educacion.calificaciones TO docente;
GRANT SELECT, INSERT, UPDATE ON educacion.asistencias TO docente;
GRANT SELECT ON educacion.estudiantes TO docente;
GRANT SELECT ON educacion.materias TO docente;

-- REPRESENTANTE
GRANT SELECT ON educacion.calificaciones TO representante;
GRANT SELECT ON educacion.asistencias TO representante;
GRANT SELECT ON educacion.estudiantes TO representante;

-- AUDITOR
GRANT SELECT ON educacion.* TO auditor;


-- Crear usuarios
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'admin123';
CREATE USER 'sec_user'@'localhost' IDENTIFIED BY 'sec123';
CREATE USER 'docente_user'@'localhost' IDENTIFIED BY 'docente123';
CREATE USER 'rep_user'@'localhost' IDENTIFIED BY 'rep123';
CREATE USER 'auditor_user'@'localhost' IDENTIFIED BY 'auditor123';

-- Asignar roles
GRANT administrador TO 'admin_user'@'localhost';
GRANT secretaria TO 'sec_user'@'localhost';
GRANT docente TO 'docente_user'@'localhost';
GRANT representante TO 'rep_user'@'localhost';
GRANT auditor TO 'auditor_user'@'localhost';

-- Activar el rol por defecto
SET DEFAULT ROLE administrador TO 'admin_user'@'localhost';
SET DEFAULT ROLE secretaria TO 'sec_user'@'localhost';
SET DEFAULT ROLE docente TO 'docente_user'@'localhost';
SET DEFAULT ROLE representante TO 'rep_user'@'localhost';
SET DEFAULT ROLE auditor TO 'auditor_user'@'localhost';


CREATE TABLE auditoria_usuarios_roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    rol VARCHAR(50) NOT NULL,
    fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO auditoria_usuarios_roles (usuario, rol) VALUES 
('admin_user', 'administrador'),
('sec_user', 'secretaria'),
('docente_user', 'docente'),
('rep_user', 'representante'),
('auditor_user', 'auditor');




-- CREACIÓN TABLA USUARIOS

CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    contrasena VARBINARY(256) NOT NULL, -- Guardamos con SHA2
    correo VARBINARY(256),              -- Encriptado con AES
    telefono VARBINARY(256),            -- Encriptado con AES
    rol ENUM('administrador', 'docente', 'representante', 'secretaria','auditor') NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- CREACION USUARIOS (EJEMPLO)

-- Insertar un docente
INSERT INTO usuarios (nombre, usuario, contrasena, correo, telefono, rol)
VALUES (
    'Carlos Pérez',
    'cperez',
    SHA2('miClaveDocente123', 256),                            -- Contraseña segura
    AES_ENCRYPT('carlos.perez@escuela.edu.ec', 'LlaveAES123'), -- Correo encriptado
    AES_ENCRYPT('0987654321', 'LlaveAES123'),                  -- Teléfono encriptado
    'docente'
);

-- Insertar un representante
INSERT INTO usuarios (nombre, usuario, contrasena, correo, telefono, rol)
VALUES (
    'María León',
    'mleon',
    SHA2('claveRepresentante456', 256),
    AES_ENCRYPT('maria.leon@familia.com', 'LlaveAES123'),
    AES_ENCRYPT('0912345678', 'LlaveAES123'),
    'representante'
);

-- CONSULTA NORMAL

SELECT * FROM usuarios;

-- CONSULTA CON DESENCRIPTACIÓN
SELECT id, nombre, usuario, rol,
    CAST(AES_DECRYPT(correo, 'LlaveAES123') AS CHAR) AS correo,
    CAST(AES_DECRYPT(telefono, 'LlaveAES123') AS CHAR) AS telefono
FROM usuarios;






-- INGRESO DE REGISTROS

-- Géneros
INSERT INTO generos (descripcion) VALUES ('Masculino'), ('Femenino');

-- Estados de matrícula
INSERT INTO estados_matricula (descripcion) VALUES ('Activa'), ('Retirada'), ('Suspendida');

-- Representantes
INSERT INTO representantes(nombres, apellidos, telefono, correo)
VALUES
  ('Araceli','Crespo','0907248829','crespo.araceli@hotmail.com'),
  ('Benito','Pastor','0951401312','b_pastor4386@outlook.com'),
  ('Liberto','Bravo','0913618408','l-bravo@yahoo.com'),
  ('Carmelo','Reyes','0951142122','carmelo_reyes@hotmail.com'),
  ('Viridiana','Jimenez','0910047595','vjimenez@yahoo.com'),
  ('Ivette','Fernandez','0924136217','fivette6284@yahoo.com'),
  ('Ramón','Vidal','0912721231','ramn.vidal7756@gmail.com'),
  ('Melina','Hernandez','0928852652','mhernandez@outlook.com'),
  ('Víctor','Marquez','0912134452','v_marquez1683@yahoo.com'),
  ('Flavio','Medina','0986383565','flavio_medina4302@outlook.com'),
  ('Ivonne','Cruz','0958223372','civonne@yahoo.com'),
  ('Florentin','Muñoz','0953723100','florentin_muoz@gmail.com'),
  ('Amalia','Arias','0956771639','a.amalia3946@hotmail.com'),
  ('Melina','Jimenez','0968698785','m.jimenez@gmail.com'),
  ('Rafa','ñez','0903626402','rez1165@outlook.com'),
  ('Eduardo','Gonzalez','0979705304','e.gonzalez7315@yahoo.com'),
  ('Jairo','Vicente','0961557763','vjairo3609@yahoo.com'),
  ('Carmelita','Marin','0960581715','c.marin1655@hotmail.com'),
  ('Maura','Herrera','0938950044','maura-herrera@gmail.com'),
  ('Wilfredo','Izquierdo','0938643353','i.wilfredo@hotmail.com'),
  ('Aldea','Gil','0928737658','aldeagil1031@gmail.com'),
  ('Guiomar','Muñoz','0973881412','muozguiomar9530@hotmail.com'),
  ('Álvaro','Marin','0912614558','l-marin@gmail.com'),
  ('Adriana','Ramirez','0940848699','r_adriana@hotmail.com'),
  ('Cristhian','Gallego','0927477158','gallego.cristhian3959@hotmail.com'),
  ('Paco','Soler','0914133608','paco.soler3047@gmail.com'),
  ('Núria','Nieto','0934706208','nria-nieto@outlook.com'),
  ('Fatima','Soto','0935736806','fatimasoto@yahoo.com'),
  ('Marisa','Suarez','0982867574','suarezmarisa2586@yahoo.com'),
  ('Gisela','Andres','0961587683','andres-gisela@outlook.com'),
  ('Lupita','Lorenzo','0986675512','lorenzolupita@yahoo.com'),
  ('Enrique','Garrido','0983752588','garrido.enrique2002@gmail.com'),
  ('Eliana','Nuñez','0981662481','nuezeliana@yahoo.com'),
  ('Antonella','Pardo','0939132583','pardo-antonella@yahoo.com'),
  ('Cristina','Alvarez','0962180585','c_alvarez6327@yahoo.com'),
  ('Víctor','Carrasco','0929457645','carrasco_vctor@yahoo.com'),
  ('Jorge','Lozano','0906471341','l-jorge2513@hotmail.com'),
  ('Fiorella','Alonso','0977135458','fiorella.alonso8630@yahoo.com'),
  ('Mariela','Soler','0914337547','s-mariela@yahoo.com'),
  ('Aldea','Crespo','0918860787','crespo.aldea@yahoo.com'),
  ('José','Diaz','0929836712','d.jos8643@outlook.com'),
  ('Helena','Santana','0987004545','santanahelena8392@hotmail.com'),
  ('Maya','Santos','0935649753','s_maya1935@hotmail.com'),
  ('Jacinto','Torres','0978713202','jacintotorres666@hotmail.com'),
  ('Alejandro','Ruiz','0913215923','a_ruiz5660@yahoo.com'),
  ('Abraham','Castillo','0986716384','a-castillo@gmail.com'),
  ('Luciano','Pastor','0937582785','pluciano@yahoo.com'),
  ('Lara','Nieto','0982381817','nieto.lara@hotmail.com'),
  ('Samara','Iba','0944223968','s-iba1921@yahoo.com'),
  ('Nazaret','Duran','0928253035','nazaret-duran@outlook.com'),
  ('Osorio','Izquierdo','0945105757','o-izquierdo@hotmail.com'),
  ('Rafa','Nieto','0913531187','rnieto@hotmail.com'),
  ('Ademar','Garcia','0983891674','g.ademar@hotmail.com'),
  ('Garbiñe','Romero','0956200407','gromero8059@hotmail.com'),
  ('Augusto','Ortega','0993854811','augusto_ortega@gmail.com'),
  ('Marta','Guerrero','0982808825','m.guerrero@gmail.com'),
  ('Antonella','Herrera','0935712872','herrera-antonella@outlook.com'),
  ('Tara','Diez','0921711636','dtara@hotmail.com'),
  ('Raphael','Santos','0933754867','r_santos8813@gmail.com'),
  ('Josefina','Nuñez','0965401543','josefina_nuez2788@hotmail.com'),
  ('Eduardo','Serrano','0911051275','e.serrano@outlook.com'),
  ('Víctor','Campos','0952665411','v.campos9384@gmail.com'),
  ('Rosario','Castro','0987695590','c.rosario7028@outlook.com'),
  ('Raul','Fernandez','0954528552','raul_fernandez6266@hotmail.com'),
  ('Pedro','Alonso','0918857471','alonsopedro2593@outlook.com'),
  ('Maura','ñez','0947073604','maura-ez@yahoo.com'),
  ('Perez','Andres','0979435682','andresperez@outlook.com'),
  ('Purita','Crespo','0943908638','crespopurita@yahoo.com'),
  ('Tamara','Gil','0948184883','tamara.gil4183@outlook.com'),
  ('Jerónimo','Rubio','0960012273','j.rubio@gmail.com'),
  ('Flavio','Peña','0905587872','f-pea3094@outlook.com'),
  ('Danilo','Lorenzo','0985393585','ldanilo5053@gmail.com'),
  ('Valeria','Pardo','0997074423','v-pardo@gmail.com'),
  ('Gloria','Santana','0976252893','gloria.santana2170@gmail.com'),
  ('Bruno','Soler','0927850788','bruno-soler6939@yahoo.com'),
  ('Martina','Sanchez','0990215479','sanchez-martina@yahoo.com'),
  ('Lorenzo','Saez','0958532469','l-saez420@gmail.com'),
  ('Dora','Mendez','0937295654','d_mendez4458@hotmail.com'),
  ('Carolina','Gonzalez','0951617716','carolinagonzalez272@gmail.com'),
  ('Pascual','Herrera','0932417163','p-herrera@gmail.com'),
  ('Charli','Marti','0950461813','marti-charli@outlook.com'),
  ('Agustina','Ferrer','0921908235','aferrer@gmail.com'),
  ('Nemesio','Delgado','0967177435','ndelgado@hotmail.com'),
  ('Víctor','Ruiz','0948176182','v-ruiz3959@gmail.com'),
  ('Tara','Lopez','0906242176','lopez_tara1889@hotmail.com'),
  ('Esperanza','Fuentes','0950452357','fuentesesperanza572@hotmail.com'),
  ('Carlota','Crespo','0922583844','crespocarlota@outlook.com'),
  ('Silvia','Gil','0944643689','gil.silvia3356@gmail.com'),
  ('Ignacio','Peña','0922375769','i_pea@gmail.com'),
  ('Ivette','Muñoz','0981224034','m.ivette8862@outlook.com'),
  ('Samuel','Lozano','0931111213','s-lozano8784@outlook.com'),
  ('Eduardo','Hernandez','0974076175','e.hernandez@yahoo.com'),
  ('Luca','Mendez','0912746232','lucamendez7395@yahoo.com'),
  ('Liberto','Ferrer','0938366954','l.ferrer1058@hotmail.com'),
  ('Ignacio','Gimenez','0936194326','igimenez5171@outlook.com'),
  ('José','Rodriguez','0993529667','j_rodriguez@gmail.com'),
  ('Diego','Diaz','0993747682','ddiaz@yahoo.com'),
  ('Morena','Gonzalez','0936274137','m-gonzalez875@hotmail.com'),
  ('Reno','Miguel','0946431607','r.miguel4240@hotmail.com'),
  ('Felipe','Ortiz','0949605684','f.ortiz@outlook.com');
  

-- Estudiantes
INSERT INTO estudiantes (cedula, genero_id, nombres, apellidos, fecha_nacimiento, direccion, telefono, correo, representante_id)
VALUES
('1787313565','1','Tina','Medina','2017-11-17','Ap #504-7763 Aliquet, Street','0908654860','tinamedina@hotmail.com',42),
  ('1782630842','2','Gaspar','Martinez','2016-10-17','467-1912 Eu, Rd.','0965423313','g.martinez9883@hotmail.com',51),
  ('1757282243','1','Rodrigo','Muñoz','2016-01-06','P.O. Box 290, 2109 Nunc Street','0973714276','rmuoz@gmail.com',66),
  ('1773684754','2','Xavi','Lopez','2017-07-01','Ap #508-4506 In, Avenue','0995909726','lopezxavi6099@gmail.com',14),
  ('1775535586','2','Hernándo','Alonso','2016-05-19','Ap #362-722 Massa. St.','0992101152','a-hernndo1780@yahoo.com',35),
  ('1728962163','1','Imelda','Delgado','2019-04-05','5692 Dictum. Avenue','0996192803','delgado-imelda160@hotmail.com',74),
  ('1790900950','1','Juana','Pascual','2019-11-26','P.O. Box 995, 8538 Dui. Rd.','0996666937','pascualjuana@yahoo.com',93),
  ('1785236956','1','Wenceslao','Esteban','2017-05-23','Ap #135-4543 Tincidunt St.','0924611179','wenceslao.esteban6885@gmail.com',82),
  ('1777060898','2','Mariano','Cabrera','2018-09-18','P.O. Box 126, 5553 Blandit Road','0957725564','c_mariano4855@hotmail.com',89),
  ('1748553634','1','Fernanda','Flores','2016-09-22','4021 Aliquam Ave','0958813752','ffernanda@yahoo.com',79),
  ('1727188764','1','Viola','Montero','2019-08-02','3975 Felis. Av.','0948454722','v_montero9508@hotmail.com',74),
  ('1757751741','1','María','Gallego','2017-05-19','685-3436 Scelerisque Avenue','0956141354','g_mara@hotmail.com',62),
  ('1794672435','1','Bianca','Sanchez','2017-11-05','P.O. Box 443, 3488 Nunc Ave','0952501138','sanchezbianca@yahoo.com',23),
  ('1722252584','1','Concepción','Vidal','2019-06-28','P.O. Box 387, 1536 Auctor Rd.','0971660928','vidalconcepcin4905@gmail.com',33),
  ('1716219760','2','Ivette','Delgado','2019-05-15','P.O. Box 278, 4678 Eu Rd.','0947601330','i.delgado7715@outlook.com',38),
  ('1714261002','1','Javier','Crespo','2019-03-04','263-8468 Eget Av.','0989557483','c-javier8821@yahoo.com',92),
  ('1792579701','2','Venancio','Saez','2016-03-09','Ap #342-4314 Aenean Avenue','0974363135','v-saez@hotmail.com',71),
  ('1784470406','1','Roberto','Martin','2017-11-21','7919 Fermentum St.','0978812814','r.martin@hotmail.com',77),
  ('1766258286','1','Pasqual','Duran','2017-12-08','Ap #206-1160 Elit, Ave','0913724836','d-pasqual1521@gmail.com',76),
  ('1763743163','1','Isabella','Nieto','2019-12-05','Ap #332-4207 Turpis. St.','0995373323','i-nieto5744@yahoo.com',57),
  ('1751063464','1','Cuauhtémoc','Soto','2017-01-30','Ap #554-3083 Aliquam St.','0946874272','soto.cuauhtmoc729@gmail.com',7),
  ('1708371292','2','Anita','Merino','2019-01-15','Ap #848-8674 Eu, Street','0977493662','a_merino@gmail.com',26),
  ('1722405642','1','Eliseo','Cruz','2019-10-01','P.O. Box 210, 6019 Ut, Av.','0926008356','eliseo_cruz7563@gmail.com',10),
  ('1762891358','2','Raphael','Moya','2018-11-23','P.O. Box 143, 159 Arcu. St.','0928467117','moya-raphael@outlook.com',9),
  ('1759152022','2','Felipe','Peña','2018-10-20','P.O. Box 118, 133 Dolor. Ave','0964357683','felipe-pea3626@hotmail.com',56),
  ('1747087798','2','Jacin','Rodriguez','2018-11-30','P.O. Box 936, 815 Erat, Avenue','0922151070','jrodriguez1048@hotmail.com',82),
  ('1746534568','1','Álvaro','ñez','2019-01-03','6152 Integer St.','0951370733','lez4611@outlook.com',65),
  ('1740323438','2','Lucio','Vicente','2019-10-11','370-8672 Placerat Rd.','0957372943','v-lucio2965@gmail.com',13),
  ('1722970594','2','Patricio','Vila','2019-01-20','Ap #677-4939 Tellus. St.','0915177514','v_patricio8080@gmail.com',38),
  ('1764277542','2','Luisa','Ramirez','2017-08-16','430-5333 Amet St.','0980579458','ramirezluisa6545@outlook.com',47),
  ('1735828473','2','Xavi','Esteban','2016-05-01','592-4529 Tincidunt. Rd.','0975856865','estebanxavi@hotmail.com',100),
  ('1737414877','2','Conchita','Perez','2018-10-15','168-5400 Enim. Road','0936375462','p.conchita3235@outlook.com',45),
  ('1766085034','2','Guido','Esteban','2018-05-04','353-3527 Praesent Av.','0983524655','g-esteban@yahoo.com',98),
  ('1722046874','1','Rita','Cortes','2018-08-04','Ap #969-8148 Leo, Street','0919327622','cortesrita@yahoo.com',77),
  ('1772631937','2','Diana','Medina','2017-08-11','P.O. Box 323, 7995 Augue Rd.','0910992039','dmedina@yahoo.com',34),
  ('1788128211','2','Luisa','Diaz','2016-08-05','P.O. Box 193, 6534 Nam St.','0937317458','d-luisa1815@yahoo.com',79),
  ('1743752205','2','Ronaldo','Fuentes','2017-11-06','Ap #489-8578 Tristique Ave','0901445245','fuentesronaldo6123@hotmail.com',67),
  ('1765306658','1','Rosendo','Hernandez','2016-07-11','848-4317 Consectetuer Avenue','0911171286','r-hernandez5543@outlook.com',80),
  ('1733722727','1','Nadia','Bravo','2017-06-06','Ap #126-500 Eleifend Road','0923771502','b.nadia9114@outlook.com',91),
  ('1741524683','1','Arnulfo','Pastor','2016-12-28','Ap #515-4209 Aliquet Av.','0992377766','a-pastor142@gmail.com',31),
  ('1710783622','2','Luz','Dominguez','2016-01-19','Ap #723-3156 Bibendum Road','0906110250','dominguez-luz6062@outlook.com',52),
  ('1710788696','1','Marta','Casado','2017-02-26','179-9945 Fusce St.','0988680317','c-marta@outlook.com',100),
  ('1797289934','2','Luciana','Pascual','2019-10-04','308-3687 Eu Rd.','0932663052','lpascual@outlook.com',20),
  ('1714271846','2','Mariana','Casado','2017-09-13','884-7622 Est Road','0926255862','m-casado5384@outlook.com',91),
  ('1715910326','1','Leonardo','Ibañez','2016-06-27','Ap #251-5354 Morbi Avenue','0923728274','l.ibaez@outlook.com',40),
  ('1762653970','1','Juanma','Gomez','2017-06-01','Ap #902-1017 Etiam Ave','0955274617','juanma-gomez8383@gmail.com',44),
  ('1722163822','2','Viridiana','Soto','2019-06-08','P.O. Box 795, 8797 Magna. Av.','0948927342','viridiana.soto@outlook.com',40),
  ('1789307187','1','Abraham','Peña','2018-01-23','Ap #836-2103 Mus. Ave','0960269403','a_pea1021@outlook.com',83),
  ('1774364433','1','Jacqueline','Hidalgo','2018-01-03','P.O. Box 450, 2371 Tincidunt. Rd.','0949541581','j.hidalgo3527@gmail.com',70),
  ('1785158845','2','Gutierre','Peña','2016-06-27','P.O. Box 806, 6931 Sapien. St.','0964036363','gpea@outlook.com',33),
  ('1737591615','1','Patricio','Leon','2018-02-25','796 Nisl. Road','0962024183','pleon8583@outlook.com',43),
  ('1771213159','2','Hilda','Ferrer','2019-04-24','P.O. Box 285, 3218 Eu Ave','0963663758','hferrer359@yahoo.com',57),
  ('1738433858','2','Manuel','Medina','2016-11-02','Ap #627-9451 Augue Av.','0967118545','medina-manuel5719@outlook.com',93),
  ('1734640821','2','Eliana','Saez','2016-05-31','2587 Mattis Ave','0943372567','e.saez3115@yahoo.com',27),
  ('1780867113','1','Federico','Iglesias','2019-05-29','447 Cubilia Rd.','0971053563','federicoiglesias5945@outlook.com',43),
  ('1712201325','2','Paulina','Nieto','2016-12-08','Ap #769-6851 Sed Rd.','0903474221','nieto_paulina1541@outlook.com',57),
  ('1720395282','1','Paco','Pascual','2017-01-15','975-6173 Pellentesque Rd.','0939344347','p-pascual@gmail.com',24),
  ('1741163257','2','Carlo','Vila','2019-04-07','Ap #703-7491 Neque Av.','0944017855','v_carlo@outlook.com',9),
  ('1712867662','1','Tomasa','Blanco','2019-12-19','907-8417 Placerat Rd.','0933214121','t.blanco@hotmail.com',51),
  ('1734634458','1','Elvira','Garcia','2018-05-19','744 Pellentesque St.','0931298646','g_elvira6331@outlook.com',61),
  ('1783537783','2','Cayetano','Navarro','2016-10-03','2254 In Road','0975513206','cnavarro@yahoo.com',74),
  ('1782011337','1','Tomás','Vicente','2019-01-02','Ap #201-3764 Integer St.','0961091574','tomsvicente3271@yahoo.com',35),
  ('1756593423','2','Eduardo','Prieto','2019-12-08','466-8187 Lacinia St.','0985124733','eduardo-prieto@gmail.com',51),
  ('1756182755','2','Carlito','Velasco','2019-01-05','Ap #907-8032 A Rd.','0919853780','c_velasco@outlook.com',79),
  ('1715092230','2','Eliana','Garrido','2019-07-12','P.O. Box 108, 874 Est Ave','0987812771','e-garrido@hotmail.com',88),
  ('1739521341','2','Amalia','Gil','2018-03-13','Ap #967-4259 Tellus. Ave','0921208456','g.amalia@outlook.com',38),
  ('1788464424','1','Salma','Vega','2018-10-02','692-9414 Nonummy Rd.','0935660916','salma.vega@yahoo.com',51),
  ('1743414478','2','Ezequiel','Flores','2016-10-02','932-3988 Suspendisse Street','0941049924','e-flores4270@gmail.com',95),
  ('1793360612','1','Erika','Dominguez','2019-08-18','6129 Vitae Avenue','0926486334','d.erika@hotmail.com',7),
  ('1765163570','1','Augusto','Herrera','2018-10-19','657-3407 Accumsan Av.','0923746852','herrera.augusto3689@hotmail.com',47),
  ('1745133434','1','Joaquín','Gonzalez','2017-12-20','3513 Erat, Avenue','0905043452','gonzalezjoaqun@gmail.com',15),
  ('1774584836','1','Fausto','Muñoz','2019-03-09','751-8524 Dictum Road','0936715178','f.muoz5729@yahoo.com',58),
  ('1780022134','2','Concepción','Santana','2018-11-03','Ap #585-2814 Aliquam Av.','0968251514','santana_concepcin@hotmail.com',19),
  ('1716426831','1','Hernándo','Ortega','2017-07-16','Ap #978-1885 Iaculis Av.','0943932725','ortegahernndo4831@yahoo.com',37),
  ('1714787742','1','Tono','Serrano','2016-02-14','6244 Erat, St.','0928593327','s.tono7018@gmail.com',43),
  ('1728016429','2','Carlota','Vazquez','2017-01-02','3529 Adipiscing Street','0983468856','c_vazquez@hotmail.com',88),
  ('1785681445','1','Paloma','Gutierrez','2016-07-24','Ap #561-9725 Varius St.','0932088609','p-gutierrez@hotmail.com',40),
  ('1794521284','1','Lana','Cano','2018-08-20','2355 Fusce Rd.','0907578806','lana-cano6994@hotmail.com',90),
  ('1762035447','2','Rafa','Cabrera','2018-01-10','551-1865 Lectus Av.','0922772070','rcabrera4351@yahoo.com',95),
  ('1736292023','1','Salvador','Castro','2019-01-05','P.O. Box 719, 1423 Sem Av.','0937136114','salvadorcastro5068@outlook.com',60),
  ('1727860514','2','Valeria','Caballero','2017-07-15','353-1185 Eu Rd.','0976332652','caballero.valeria@gmail.com',49),
  ('1732649864','2','Santiago','Gutierrez','2017-02-13','5430 Faucibus Rd.','0951252227','santiago.gutierrez1809@yahoo.com',77),
  ('1798921868','2','Ileana','Montero','2017-12-06','Ap #676-6465 Sem Rd.','0981516851','i-montero@hotmail.com',11),
  ('1762614562','1','Diana','Muñoz','2016-05-01','Ap #579-5344 Aliquet Av.','0967067884','diana.muoz@gmail.com',30),
  ('1770721315','1','Ricardo','ñez','2018-03-24','Ap #739-5874 Nunc Av.','0974772223','ricardo.ez577@hotmail.com',19),
  ('1769128063','1','Rosa','Torres','2016-03-15','6233 Amet Road','0944833665','torres_rosa2482@hotmail.com',16),
  ('1742696668','1','Pepe','Moreno','2017-12-11','466-1479 Lacus. Road','0973374698','moreno.pepe@yahoo.com',7),
  ('1769847140','1','Juanfran','Suarez','2016-11-28','130-7193 Quis, St.','0955633542','juanfran_suarez@yahoo.com',40),
  ('1774027783','2','Lana','Gil','2018-11-17','Ap #256-7256 Aliquam, Ave','0936212682','l_gil@yahoo.com',90),
  ('1752581179','1','Marisol','Merino','2016-11-23','874-2713 Aliquet. Road','0968154985','m.merino9487@yahoo.com',16),
  ('1774340458','2','Margarita','Marti','2017-05-14','272 Egestas, Road','0948482794','m_marti@outlook.com',16),
  ('1753312948','1','Alonso','Lozano','2018-11-08','P.O. Box 483, 1755 A, Rd.','0927288513','alonso.lozano5030@outlook.com',92),
  ('1718892567','2','Carlito','Delgado','2017-04-08','835-3902 Sed Av.','0958896335','c.delgado@hotmail.com',43),
  ('1715185524','1','Lana','Vidal','2018-08-04','Ap #729-6565 Tortor. St.','0979871585','l-vidal@yahoo.com',83),
  ('1766035995','2','Gonzalo','Ferrer','2019-04-07','1282 Quis Street','0966347391','ferrer_gonzalo2400@gmail.com',44),
  ('1714791841','1','Carlos','Diez','2019-11-08','693-1296 Cursus Rd.','0951399479','diez-carlos4302@yahoo.com',46),
  ('1735388681','2','Natalia','Guerrero','2018-08-05','Ap #109-6300 Arcu. Street','0987469422','guerreronatalia@outlook.com',25),
  ('1738879713','1','Patricio','Reyes','2018-03-05','9621 Vitae St.','0950182157','patricio-reyes@outlook.com',60),
  ('1769732435','2','Ademar','Nuñez','2018-01-14','736-1977 Non, Avenue','0976542733','n_ademar1861@outlook.com',93),
  ('1762414899','2','Silvia','Carrasco','2019-12-25','P.O. Box 368, 8288 Iaculis St.','0902197176','carrasco.silvia@hotmail.com',19),
  ('1705982345','2','List','Moreno','2017-08-31','Ap #430-8653 Nec Av.','0925650372','m-list7222@hotmail.com',51),
  ('1732263276','2','Pascual','Molina','2016-02-12','P.O. Box 932, 1678 Nec Ave','0966330074','molina-pascual3382@hotmail.com',98),
  ('1789110245','1','Ines','Cabrera','2016-09-30','Ap #744-4620 Aliquam St.','0944159468','i_cabrera34@yahoo.com',67),
  ('1755256647','1','Fernando','Diez','2019-08-22','592-6518 Sed Road','0950964439','fdiez@outlook.com',10),
  ('1735270641','1','Geronimo','Bravo','2018-08-31','Ap #768-7451 At Road','0968326818','geronimo_bravo9258@hotmail.com',45),
  ('1782874453','2','Sebastian','Ortega','2017-05-15','P.O. Box 821, 7182 Nibh Avenue','0930034173','ortega_sebastian@hotmail.com',10),
  ('1756285507','1','Catalina','Herrera','2016-01-29','2887 Sit Road','0966616583','cherrera@hotmail.com',9),
  ('1735671348','1','Imelda','Vazquez','2016-10-14','Ap #521-8791 Eleifend, Street','0925839374','v.imelda@yahoo.com',62),
  ('1724779504','2','Marisol','Medina','2018-06-26','9171 Phasellus Street','0934646853','m_medina@yahoo.com',31),
  ('1755730344','1','Aníbal','Navarro','2016-05-08','P.O. Box 903, 1019 Convallis St.','0948790338','n-anbal@gmail.com',4),
  ('1799586780','1','Elvira','Garcia','2018-03-24','621-372 Ligula. Avenue','0989359603','garcia-elvira6003@yahoo.com',60),
  ('1781816932','2','Iris','Moya','2019-01-13','Ap #380-8196 Parturient Street','0956258514','moyairis6259@outlook.com',63),
  ('1787713006','2','Claudia','Gonzalez','2016-04-06','Ap #544-1024 Orci. Rd.','0935546892','gonzalez-claudia9443@yahoo.com',11),
  ('1727841181','2','Yazmin','Vega','2016-07-24','Ap #937-5335 Risus. Rd.','0936242473','vega_yazmin@gmail.com',55),
  ('1711494678','2','Abel','Gonzalez','2018-08-23','1948 Auctor Road','0929721282','abel.gonzalez4904@outlook.com',85),
  ('1765479413','1','Urraca','Esteban','2016-07-19','428-6923 Quis, Road','0975266976','esteban-urraca3140@gmail.com',92),
  ('1789966749','2','Milena','Pardo','2019-06-22','Ap #296-7236 Torquent Street','0978546221','pardo.milena9404@hotmail.com',48),
  ('1782821821','2','Manuela','Saez','2016-08-07','P.O. Box 859, 7675 Nec Road','0962443719','saez.manuela7200@gmail.com',67),
  ('1763517052','2','Nazaret','Muñoz','2017-11-24','593 A Rd.','0911377324','muoz-nazaret@outlook.com',57),
  ('1723503384','2','Silvina','Marti','2016-09-13','260-7259 Cursus Ave','0904358841','marti-silvina4844@outlook.com',23),
  ('1748667135','1','Angel','Sanz','2019-05-05','7991 Quam Ave','0919384581','a_sanz@yahoo.com',12),
  ('1751974777','1','Flora','Herrera','2018-03-06','730-5700 Magna. Road','0922652097','h_flora@hotmail.com',2),
  ('1789584476','1','Xavi','Castro','2019-08-12','Ap #462-4497 Ut, Road','0963746756','x_castro3169@outlook.com',2),
  ('1732263406','2','Antonella','Moya','2019-04-09','Ap #619-571 Eu Road','0925802938','mantonella@hotmail.com',61),
  ('1784946005','2','Juan','Medina','2016-03-20','146-2525 Quisque Av.','0950940339','jmedina6378@hotmail.com',57),
  ('1755404064','2','Agustín','Flores','2018-08-23','1432 Magnis Rd.','0966257306','a_flores2479@hotmail.com',23),
  ('1714039875','1','Araceli','Hernandez','2016-01-06','365-1128 Metus Street','0993175626','h.araceli2218@outlook.com',29),
  ('1771247563','1','Carlos','Muñoz','2019-10-03','6095 Lobortis Avenue','0969843133','c.muoz3094@gmail.com',99),
  ('1715906964','1','Carla','Guerrero','2018-11-29','657-3003 Quis St.','0949537393','cguerrero@yahoo.com',93),
  ('1785149853','1','Gloria','Medina','2017-04-16','8230 Nunc Avenue','0936931528','medina_gloria9068@hotmail.com',79),
  ('1738609855','2','Luisa','Castillo','2017-05-21','839-5404 Lacus St.','0964514153','luisa-castillo6142@gmail.com',14),
  ('1771831698','2','Raquel','Garrido','2019-09-21','1315 Vel Road','0963524217','r-garrido2776@outlook.com',82),
  ('1760076985','2','Cuauhtémoc','Santana','2017-09-08','439-4837 At, Rd.','0916754236','c-santana7861@outlook.com',56),
  ('1725088381','1','Niño','Ortiz','2017-02-20','Ap #274-8039 Curabitur St.','0926892344','o-nio@outlook.com',69),
  ('1747111235','2','Isabella','Diez','2019-04-24','272-4093 Nec Rd.','0988714019','diez-isabella@yahoo.com',61),
  ('1733810565','1','Aldea','Vidal','2017-10-03','827-8329 Sed Street','0951517678','vidal-aldea8036@yahoo.com',99),
  ('1710471361','2','Dario','Ferrer','2017-08-24','907-9735 Non Ave','0938736551','d_ferrer827@outlook.com',24),
  ('1798286031','1','Gabriela','Diez','2019-09-25','485-9135 Risus. Avenue','0916399271','diez-gabriela7847@gmail.com',86),
  ('1744527786','1','Aníbal','Alvarez','2019-11-12','814-4284 Ullamcorper, Ave','0925629249','a.anbal470@yahoo.com',73),
  ('1766251742','1','Marisela','Vazquez','2018-10-15','234-768 Fringilla, Avenue','0908859791','marisela.vazquez@gmail.com',24),
  ('1721788839','1','Augusto','Romero','2018-03-16','Ap #930-4042 Congue, Rd.','0924182201','aromero5335@outlook.com',14),
  ('1737853565','2','Ana','Marin','2016-03-20','4666 Libero. Rd.','0952352076','marin.ana9111@hotmail.com',15),
  ('1769671032','1','Isa','Ramos','2016-04-01','9516 Arcu. Rd.','0938675453','ramos_isa@yahoo.com',43),
  ('1702261192','2','Marco','Muñoz','2017-11-29','344-7471 Purus. Road','0929514837','m.muoz@outlook.com',65),
  ('1754487916','2','Rita','Fuentes','2017-02-17','Ap #698-3443 Nulla St.','0945571443','fuentes.rita@yahoo.com',39),
  ('1752570778','1','Xiomara','Pascual','2017-06-16','Ap #652-1841 Montes, St.','0904826467','xiomara-pascual5905@gmail.com',61),
  ('1746438569','1','Silvina','Carmona','2016-09-07','642-7635 Felis. Road','0971881625','carmonasilvina6179@yahoo.com',32),
  ('1792855315','1','Luz','Jimenez','2018-12-06','537-5627 Risus St.','0973148032','jimenez.luz120@outlook.com',67),
  ('1767981762','2','Noe','Fernandez','2019-04-11','Ap #269-5361 Ornare St.','0932185362','f_noe@outlook.com',57),
  ('1781683232','1','Ezequiel','Cabrera','2017-08-24','626-2920 Cursus Ave','0936357257','e.cabrera@yahoo.com',31),
  ('1700130174','2','Juanfran','Santos','2016-11-03','741-1644 Sollicitudin Rd.','0987643167','santos_juanfran9341@gmail.com',7),
  ('1725361682','1','Claudia','Garcia','2019-12-16','288-9141 Quam Road','0964620654','garcia_claudia@gmail.com',58),
  ('1711448266','1','Obdulio','Carrasco','2017-07-24','P.O. Box 959, 6015 Aenean Rd.','0904401843','c_obdulio2205@gmail.com',86),
  ('1747564076','1','Jhon','Nieto','2017-03-05','Ap #150-8142 Eget Street','0948185533','jhon-nieto4822@hotmail.com',52),
  ('1725713217','1','Reno','Muñoz','2017-08-30','Ap #998-6765 Quisque Avenue','0983456433','r-muoz@yahoo.com',30),
  ('1727251862','1','Javier','Nuñez','2017-07-19','752-1151 Eget Avenue','0935432672','j_nuez@outlook.com',14),
  ('1717412869','2','Carlota','Gallego','2019-05-01','2505 Cursus Rd.','0971595981','c.gallego@yahoo.com',69),
  ('1785843967','1','Magdalena','Gimenez','2018-11-13','Ap #445-7333 Pulvinar Street','0947421458','m_gimenez6944@gmail.com',53),
  ('1748128414','1','Carla','Saez','2016-05-18','544-3760 Montes, Ave','0969370172','carlasaez@yahoo.com',25),
  ('1786287657','1','Samuel','Soler','2018-05-12','8655 Gravida. Ave','0918565116','s-soler6914@outlook.com',98),
  ('1782746461','2','Justina','Casado','2019-11-20','2767 Interdum. Street','0914756685','j.casado@yahoo.com',15),
  ('1777135875','2','Angel','Ibañez','2016-11-30','436-6726 Augue. St.','0946011026','i_angel@gmail.com',17),
  ('1713488624','1','Jairo','Castro','2018-01-24','7758 Nec Road','0939914057','jcastro4186@hotmail.com',19),
  ('1768802355','1','Julia','Vazquez','2018-06-20','903-9889 Nulla Road','0900421882','vjulia8067@outlook.com',25),
  ('1753769252','2','José','Vazquez','2016-04-03','P.O. Box 136, 994 Aliquet. Road','0945934005','vazquezjos@outlook.com',86),
  ('1793050832','1','Jacqueline','Casado','2016-02-05','Ap #341-493 Nec St.','0941357732','jcasado@outlook.com',66),
  ('1775346003','1','Julio','Miguel','2017-03-27','Ap #736-9253 Nulla Rd.','0917114798','miguel-julio9499@yahoo.com',90),
  ('1712339718','1','Flora','Cano','2019-11-26','Ap #733-8151 Malesuada Road','0994518064','f.cano9296@yahoo.com',76),
  ('1757335283','1','Maximiliano','Flores','2019-04-14','Ap #609-1718 Vitae, St.','0943937528','floresmaximiliano6647@outlook.com',16),
  ('1764087734','1','Raquel','Pastor','2019-02-23','803-9192 Nec, St.','0984436404','rpastor9779@hotmail.com',21),
  ('1768567574','2','Sixto','Saez','2018-06-23','799-6765 Luctus Av.','0973044701','s.saez1144@outlook.com',10),
  ('1743393824','2','Perez','Nuñez','2018-08-21','429-2353 Venenatis St.','0915074865','p.nuez@gmail.com',75),
  ('1747478154','1','Beto','Romero','2017-01-27','867-5627 Urna Ave','0954376768','b_romero@gmail.com',90),
  ('1793241832','2','Antonio','ñez','2019-09-25','Ap #123-7011 Vitae, St.','0923378446','ez.antonio6465@hotmail.com',12),
  ('1766863877','2','Primitivo','Ramirez','2018-07-31','239-540 Urna St.','0975154540','p_ramirez@gmail.com',69),
  ('1786840307','1','Bruno','Aguilar','2017-05-23','269-2244 Porttitor Avenue','0925541970','baguilar109@hotmail.com',19),
  ('1714188285','1','Cari','Prieto','2018-03-24','Ap #443-6170 Eu, St.','0953228215','prieto.cari1376@outlook.com',2),
  ('1773462774','1','Dolores','Gallego','2019-10-30','987 Et, Rd.','0969341485','dgallego@yahoo.com',76),
  ('1751438168','1','Eugenia','Esteban','2016-03-27','Ap #746-2699 Pede. Ave','0944614235','e_esteban@hotmail.com',72),
  ('1732512865','2','Rolando','Reyes','2017-08-13','1344 Fusce Avenue','0935458128','r.rolando3044@yahoo.com',97),
  ('1776726175','1','Tonio','Herrero','2019-03-05','132-4524 Tempus St.','0952742765','t_herrero4216@outlook.com',29),
  ('1712146830','2','Nazaret','Gomez','2018-03-30','Ap #220-5598 Mauris St.','0974183128','n_gomez@gmail.com',85),
  ('1716412143','1','Manuela','Cabrera','2017-02-07','Ap #120-7381 Sit Avenue','0925288497','cabrera-manuela2155@gmail.com',22),
  ('1734462376','1','Mario','Peña','2016-07-16','770-7697 Eget Rd.','0948936449','mario.pea@hotmail.com',33),
  ('1723107021','2','Irene','Rubio','2019-03-22','553 Consectetuer, Street','0942788253','irubio@yahoo.com',68),
  ('1742326701','2','Tina','Ruiz','2016-10-29','P.O. Box 795, 8248 Dis Av.','0961532715','t.ruiz@gmail.com',49),
  ('1775862423','2','Iris','Fuentes','2016-02-18','566-6248 Ipsum Rd.','0913591648','fuentes-iris@outlook.com',43),
  ('1764717978','2','List','Andres','2017-04-20','9615 At St.','0954781152','landres@gmail.com',54),
  ('1765244341','1','Osvaldo','Castillo','2019-08-02','837-650 Integer Av.','0951489338','castillo_osvaldo9449@hotmail.com',38),
  ('1748082511','1','Obdulio','Molina','2016-03-08','9660 Tincidunt, St.','0969049074','o-molina@outlook.com',97),
  ('1716480672','1','Wilfredo','Molina','2017-08-26','4188 Vitae Street','0912461918','molinawilfredo@yahoo.com',84),
  ('1762431384','1','Paulina','Velasco','2018-07-30','Ap #668-3758 Accumsan Street','0971681409','p.velasco6732@yahoo.com',7),
  ('1736551338','2','Carlos','Lorenzo','2017-06-29','3725 Sed Road','0976225253','c_lorenzo6781@outlook.com',17),
  ('1771449729','2','Tara','Alonso','2016-06-30','P.O. Box 656, 9041 Ut Road','0982033498','tara.alonso8093@outlook.com',83),
  ('1794388325','1','Vilma','Blanco','2018-12-16','Ap #934-3214 Felis. Rd.','0996046180','blanco_vilma6778@hotmail.com',35),
  ('1748382255','2','Ademar','Izquierdo','2016-05-28','412-3665 Suspendisse St.','0978564648','ademar_izquierdo9460@hotmail.com',12),
  ('1734165118','1','Aarón','Marquez','2017-05-26','Ap #184-4136 Mauris St.','0913144420','a_marquez3183@hotmail.com',92),
  ('1722569272','1','Fernanda','Crespo','2016-01-24','Ap #692-9186 Curabitur Ave','0936866360','c_fernanda@hotmail.com',25),
  ('1784862079','1','Lucero','Alvarez','2018-09-28','P.O. Box 582, 9955 Arcu Street','0928154653','l_alvarez8605@outlook.com',25),
  ('1788170873','2','Marina','Muñoz','2018-09-11','Ap #203-9097 Fermentum Ave','0954435236','marina.muoz4152@hotmail.com',78);
  
-- Docentes
INSERT INTO docentes (nombre, apellidos, titulo_obtenido, telefono, correo)
VALUES
('Ana', 'Mendoza', 'Licenciado en Ciencias Sociales', '0956185943', 'ana.mendoza30@mail.com'),
('Raúl', 'Ortega', 'Licenciado en Ciencias Sociales', '0985080140', 'raúl.ortega93@mail.com'),
('María', 'Torres', 'Licenciado en Enseñanza del Inglés', '0950841618', 'maría.torres53@mail.com'),
('Luis', 'Cordero', 'Licenciado en Enseñanza del Inglés', '0940564724', 'luis.cordero88@mail.com'),
('Verónica', 'López', 'Licenciado en Lengua y Literatura', '0918883702', 'verónica.lópez58@mail.com'),
('Verónica', 'Torres', 'Licenciado en Ciencias Naturales', '0980613986', 'verónica.torres44@mail.com'),
('Elena', 'Reyes', 'Licenciado en Ciencias de la Educación mención Matemáticas', '0984717315', 'elena.reyes21@mail.com'),
('Andrés', 'López', 'Licenciado en Lengua y Literatura', '0926962223', 'andrés.lópez69@mail.com'),
('Elena', 'Pérez', 'Licenciado en Lengua y Literatura', '0931471224', 'elena.pérez2@mail.com'),
('María', 'Sánchez', 'Licenciado en Enseñanza del Inglés', '0954654151', 'maría.sánchez70@mail.com'),
('Raúl', 'Rodríguez', 'Licenciado en Enseñanza del Inglés', '0900775514', 'raúl.rodríguez80@mail.com'),
('Luis', 'Mendoza', 'Licenciado en Ciencias Naturales', '0934411574', 'luis.mendoza93@mail.com'),
('Carlos', 'Rodríguez', 'Licenciado en Ciencias Naturales', '0978346928', 'carlos.rodríguez66@mail.com'),
('Sofía', 'Castro', 'Licenciado en Ciencias Naturales', '0978746017', 'sofía.castro13@mail.com'),
('Ana', 'Gómez', 'Licenciado en Enseñanza del Inglés', '0953043513', 'ana.gómez71@mail.com'),
('María', 'Ortega', 'Licenciado en Ciencias Sociales', '0918708199', 'maría.ortega20@mail.com'),
('Laura', 'Gómez', 'Licenciado en Ciencias de la Educación mención Matemáticas', '0999562172', 'laura.gómez63@mail.com'),
('Ana', 'Ramos', 'Licenciado en Enseñanza del Inglés', '0917136596', 'ana.ramos2@mail.com'),
('Isabel', 'Flores', 'Licenciado en Enseñanza del Inglés', '0932291090', 'isabel.flores51@mail.com'),
('Diego', 'Castro', 'Licenciado en Ciencias Naturales', '0981447690', 'diego.castro75@mail.com');


-- Materias
INSERT INTO materias (nombre, descripcion, horas_semanales)
VALUES
('Estudios Sociales', 'Análisis de la sociedad y su historia.', 4),
('Inglés', 'Aprendizaje básico del idioma inglés.', 3),
('Lengua y Literatura', 'Estudio del idioma y obras literarias.', 5),
('Ciencias Naturales', 'Exploración del mundo natural y sus fenómenos.', 4),
('Matemáticas', 'Razonamiento lógico y resolución de problemas numéricos.', 5);


-- Paralelos
INSERT INTO paralelos (nombre_paralelo, grado, cupo_maximo)
VALUES
('A', 'Primero', 30),
('B', 'Primero', 28),
('A', 'Segundo', 27),
('B', 'Segundo', 30),
('A', 'Tercero', 29),
('B', 'Tercero', 28),
('A', 'Cuarto', 31),
('B', 'Cuarto', 27),
('A', 'Quinto', 28),
('B', 'Quinto', 30),
('A', 'Sexto', 27),
('B', 'Sexto', 31),
('A', 'Séptimo', 29),
('B', 'Séptimo', 28);


-- HORARIOS
INSERT INTO horarios (dia, hora_inicio, hora_fin)
VALUES
-- Lunes
('Lunes', '07:00:00', '09:00:00'),
('Lunes', '09:00:00', '11:00:00'),
('Lunes', '11:00:00', '13:00:00'),

-- Martes
('Martes', '07:00:00', '09:00:00'),
('Martes', '09:00:00', '11:00:00'),
('Martes', '11:00:00', '13:00:00'),

-- Miércoles
('Miércoles', '07:00:00', '09:00:00'),
('Miércoles', '09:00:00', '11:00:00'),
('Miércoles', '11:00:00', '13:00:00'),

-- Jueves
('Jueves', '07:00:00', '09:00:00'),
('Jueves', '09:00:00', '11:00:00'),
('Jueves', '11:00:00', '13:00:00'),

-- Viernes
('Viernes', '07:00:00', '09:00:00'),
('Viernes', '09:00:00', '11:00:00'),
('Viernes', '11:00:00', '13:00:00');



-- Asignación Materias
INSERT INTO asignacion_materias (materia_id, docente_id, paralelo_id, horario_id)
VALUES 
(4,6,10,12),
(4,14,1,7),
(2,3,6,14),
(1,1,6,9),
(4,13,9,3),
(3,8,8,1),
(3,9,7,15),
(5,7,4,6),
(4,12,5,8),
(5,17,7,4),
(5,7,13,10),
(2,4,8,5),
(4,14,8,13),
(2,19,7,1),
(2,15,11,11),
(1,16,12,7),
(2,3,12,2),
(1,2,1,8),
(4,20,4,9),
(4,13,4,3),
(2,11,12,15),
(1,16,11,10),
(2,15,12,12),
(1,2,4,4),
(3,9,9,6),
(2,4,5,14),
(5,17,10,7),
(5,7,12,13),
(3,5,2,11),
(5,7,2,5);

-- Matriculas
INSERT INTO matriculas (estudiante_id, paralelo_id, fecha_matricula, estado_id)
VALUES 
(1,10,'2025-07-05',2),
(2,10,'2025-07-05',2),
(3,7,'2025-07-08',2),
(4,7,'2025-07-12',3),
(5,8,'2025-07-03',2),
(6,11,'2025-07-13',3),
(7,13,'2025-07-06',1),
(8,5,'2025-07-11',2),
(9,12,'2025-07-08',1),
(10,7,'2025-07-11',1),
(11,12,'2025-07-04',3),
(12,6,'2025-07-04',2),
(13,10,'2025-07-06',3),
(14,12,'2025-07-09',1),
(15,2,'2025-07-06',3),
(16,9,'2025-07-07',1),
(17,2,'2025-07-12',2),
(18,6,'2025-07-14',2),
(19,7,'2025-07-05',2),
(20,8,'2025-07-07',1),
(21,2,'2025-07-03',1),
(22,9,'2025-07-14',2),
(23,12,'2025-07-15',2),
(24,6,'2025-07-05',1),
(25,9,'2025-07-11',2),
(26,6,'2025-07-10',1),
(27,11,'2025-07-09',3),
(28,7,'2025-07-04',1),
(29,6,'2025-07-08',1),
(30,3,'2025-07-04',2),
(31,9,'2025-07-12',3),
(32,14,'2025-07-12',1),
(33,11,'2025-07-12',1),
(34,8,'2025-07-09',1),
(35,10,'2025-07-10',2),
(36,9,'2025-07-08',2),
(37,6,'2025-07-13',3),
(38,3,'2025-07-06',3),
(39,6,'2025-07-13',2),
(40,4,'2025-07-03',2),
(41,13,'2025-07-12',2),
(42,8,'2025-07-14',3),
(43,7,'2025-07-05',2),
(44,7,'2025-07-10',1),
(45,8,'2025-07-13',2),
(46,5,'2025-07-07',1),
(47,7,'2025-07-03',3),
(48,6,'2025-07-08',2),
(49,8,'2025-07-11',2),
(50,9,'2025-07-11',2),
(51,8,'2025-07-13',1),
(52,2,'2025-07-03',2),
(53,14,'2025-07-10',3),
(54,13,'2025-07-08',2),
(55,4,'2025-07-09',1),
(56,11,'2025-07-03',2),
(57,5,'2025-07-04',2),
(58,11,'2025-07-02',3),
(59,6,'2025-07-13',1),
(60,7,'2025-07-15',2),
(61,3,'2025-07-03',2),
(62,13,'2025-07-03',2),
(63,4,'2025-07-11',2),
(64,7,'2025-07-15',2),
(65,9,'2025-07-03',1),
(66,11,'2025-07-12',3),
(67,6,'2025-07-04',3),
(68,6,'2025-07-09',2),
(69,6,'2025-07-04',2),
(70,4,'2025-07-12',2),
(71,2,'2025-07-07',2),
(72,11,'2025-07-09',2),
(73,3,'2025-07-02',1),
(74,13,'2025-07-15',2),
(75,7,'2025-07-10',2),
(76,6,'2025-07-07',3),
(77,7,'2025-07-10',3),
(78,11,'2025-07-12',1),
(79,13,'2025-07-10',1),
(80,4,'2025-07-12',1),
(81,6,'2025-07-08',1),
(82,11,'2025-07-09',2),
(83,4,'2025-07-03',3),
(84,3,'2025-07-15',3),
(85,5,'2025-07-11',1),
(86,6,'2025-07-02',1),
(87,9,'2025-07-08',2),
(88,10,'2025-07-04',2),
(89,6,'2025-07-04',1),
(90,5,'2025-07-15',2),
(91,9,'2025-07-03',2),
(92,13,'2025-07-15',2),
(93,8,'2025-07-03',1),
(94,4,'2025-07-08',2),
(95,7,'2025-07-13',1),
(96,8,'2025-07-05',2),
(97,2,'2025-07-15',2),
(98,11,'2025-07-14',1),
(99,14,'2025-07-11',3),
(100,4,'2025-07-04',1),
(101,13,'2025-07-07',2),
(102,2,'2025-07-05',3),
(103,3,'2025-07-11',3),
(104,6,'2025-07-07',3),
(105,4,'2025-07-05',3),
(106,11,'2025-07-02',1),
(107,11,'2025-07-04',2),
(108,14,'2025-07-14',2),
(109,12,'2025-07-03',1),
(110,9,'2025-07-03',3),
(111,5,'2025-07-15',3),
(112,7,'2025-07-11',2),
(113,5,'2025-07-13',3),
(114,10,'2025-07-09',1),
(115,11,'2025-07-04',3),
(116,13,'2025-07-02',2),
(117,2,'2025-07-05',2),
(118,9,'2025-07-13',2),
(119,13,'2025-07-02',2),
(120,13,'2025-07-02',3),
(121,12,'2025-07-15',2),
(122,13,'2025-07-12',2),
(123,11,'2025-07-07',3),
(124,10,'2025-07-08',3),
(125,3,'2025-07-09',2),
(126,11,'2025-07-13',3),
(127,13,'2025-07-07',2),
(128,11,'2025-07-09',2),
(129,2,'2025-07-09',2),
(130,5,'2025-07-09',2),
(131,1,'2025-07-04',2),
(132,12,'2025-07-15',2),
(133,6,'2025-07-07',1),
(134,3,'2025-07-06',2),
(135,13,'2025-07-04',2),
(136,6,'2025-07-07',1),
(137,2,'2025-07-06',2),
(138,2,'2025-07-06',2),
(139,4,'2025-07-12',3),
(140,4,'2025-07-08',2),
(141,14,'2025-07-09',1),
(142,7,'2025-07-09',2),
(143,2,'2025-07-13',1),
(144,9,'2025-07-06',2),
(145,10,'2025-07-02',2),
(146,11,'2025-07-09',3),
(147,9,'2025-07-04',2),
(148,10,'2025-07-15',2),
(149,12,'2025-07-02',2),
(150,3,'2025-07-05',2),
(151,11,'2025-07-01',3),
(152,5,'2025-07-07',3),
(153,2,'2025-07-03',2),
(154,4,'2025-07-02',2),
(155,2,'2025-07-02',2),
(156,10,'2025-07-14',2),
(157,9,'2025-07-04',3),
(158,12,'2025-07-05',1),
(159,4,'2025-07-03',3),
(160,10,'2025-07-12',2),
(161,11,'2025-07-13',1),
(162,2,'2025-07-13',3),
(163,7,'2025-07-03',1),
(164,12,'2025-07-10',2),
(165,14,'2025-07-11',2),
(166,13,'2025-07-12',2),
(167,2,'2025-07-05',2),
(168,12,'2025-07-08',2),
(169,2,'2025-07-09',1),
(170,14,'2025-07-08',2),
(171,14,'2025-07-10',3),
(172,7,'2025-07-06',2),
(173,12,'2025-07-11',1),
(174,7,'2025-07-04',3),
(175,4,'2025-07-08',2),
(176,1,'2025-07-07',2),
(177,12,'2025-07-03',2),
(178,5,'2025-07-14',2),
(179,10,'2025-07-03',1),
(180,1,'2025-07-04',1),
(181,3,'2025-07-11',2),
(182,5,'2025-07-05',2),
(183,1,'2025-07-13',1),
(184,14,'2025-07-07',2),
(185,1,'2025-07-02',3),
(186,10,'2025-07-03',1),
(187,3,'2025-07-09',1),
(188,3,'2025-07-11',2),
(189,3,'2025-07-15',2),
(190,12,'2025-07-10',3),
(191,11,'2025-07-03',1),
(192,12,'2025-07-12',2),
(193,13,'2025-07-12',1),
(194,9,'2025-07-15',2),
(195,2,'2025-07-08',2),
(196,4,'2025-07-13',2),
(197,4,'2025-07-12',3),
(198,3,'2025-07-06',3),
(199,2,'2025-07-05',3),
(200,2,'2025-07-13',2);


-- Calificaciones
INSERT INTO calificaciones (estudiante_id, asignacion_id, trimestre, nota)
VALUES
(1,1,1,4),
(2,25,3,3),
(3,30,2,6),
(4,10,1,7),
(5,22,1,5),
(6,13,2,6),
(7,10,3,6),
(8,15,3,6),
(9,5,1,10),
(10,26,2,8),
(11,4,2,5),
(12,5,2,7),
(13,25,1,6),
(14,3,1,4),
(15,28,2,8),
(16,14,3,6),
(17,14,3,7),
(18,13,1,5),
(19,9,2,6),
(20,24,2,5),
(21,20,1,8),
(22,3,3,10),
(23,16,2,7),
(24,28,2,5),
(25,18,2,3),
(26,6,1,8),
(27,26,2,10),
(28,15,1,4),
(29,28,2,5),
(30,2,2,6),
(31,8,1,7),
(32,19,1,6),
(33,11,2,5),
(34,26,3,8),
(35,3,2,4),
(36,27,1,10),
(37,15,2,10),
(38,10,2,8),
(39,2,2,4),
(40,14,2,7),
(41,24,2,7),
(42,16,2,10),
(43,26,2,5),
(44,26,3,5),
(45,11,2,9),
(46,1,2,10),
(47,26,2,7),
(48,9,1,6),
(49,19,1,10),
(50,11,2,3),
(51,1,2,4),
(52,21,3,10),
(53,6,2,4),
(54,20,1,4),
(55,20,2,7),
(56,16,2,9),
(57,27,2,7),
(58,11,2,8),
(59,8,2,4),
(60,3,3,9),
(61,17,1,5),
(62,26,2,7),
(63,29,2,3),
(64,20,2,6),
(65,2,3,9),
(66,19,3,7),
(67,26,2,8),
(68,26,2,7),
(69,11,2,10),
(70,4,2,9),
(71,7,2,6),
(72,7,2,6),
(73,14,2,4),
(74,27,2,7),
(75,20,1,3),
(76,22,2,8),
(77,23,1,8),
(78,12,1,8),
(79,22,2,5),
(80,22,2,6),
(81,6,2,6),
(82,22,2,8),
(83,16,2,8),
(84,10,2,9),
(85,15,2,9),
(86,8,3,8),
(87,6,2,7),
(88,27,2,5),
(89,8,2,4),
(90,29,2,5),
(91,18,2,6),
(92,26,2,5),
(93,13,3,10),
(94,29,1,8),
(95,17,2,6),
(96,6,3,8),
(97,29,1,7),
(98,21,2,6),
(99,16,3,7),
(100,13,2,5),
(101,10,2,8),
(102,19,3,6),
(103,2,1,7),
(104,18,2,9),
(105,28,2,8),
(106,28,1,4),
(107,9,2,5),
(108,12,2,8),
(109,17,3,4),
(110,28,2,6),
(111,12,3,4),
(112,6,2,5),
(113,14,2,7),
(114,19,3,7),
(115,12,3,9),
(116,5,3,5),
(117,9,2,7),
(118,21,2,9),
(119,7,2,9),
(120,21,2,6),
(121,10,2,3),
(122,30,2,4),
(123,26,2,3),
(124,3,2,7),
(125,20,2,4),
(126,25,2,4),
(127,23,3,6),
(128,28,2,3),
(129,11,1,7),
(130,18,2,5),
(131,11,2,7),
(132,26,2,7),
(133,11,2,7),
(134,9,1,5),
(135,7,2,8),
(136,27,2,4),
(137,4,2,9),
(138,27,1,8),
(139,1,3,6),
(140,22,2,9),
(141,30,2,8),
(142,18,3,7),
(143,18,1,8),
(144,13,3,5),
(145,5,3,10),
(146,14,1,5),
(147,12,3,10),
(148,21,2,6),
(149,10,2,9),
(150,16,3,9),
(151,2,2,7),
(152,20,2,9),
(153,25,3,4),
(154,27,3,5),
(155,24,1,8),
(156,10,1,8),
(157,30,1,7),
(158,23,1,6),
(159,12,1,6),
(160,21,1,4),
(161,16,2,8),
(162,9,2,3),
(163,16,1,4),
(164,28,3,3),
(165,25,1,7),
(166,25,1,8),
(167,20,2,8),
(168,9,2,4),
(169,22,2,3),
(170,20,2,4),
(171,19,2,5),
(172,29,2,5),
(173,23,1,4),
(174,9,3,6),
(175,21,1,6),
(176,23,2,8),
(177,28,2,4),
(178,26,3,6),
(179,14,3,4),
(180,28,2,8),
(181,3,1,10),
(182,18,2,8),
(183,5,2,3),
(184,17,2,5),
(185,4,2,4),
(186,26,1,7),
(187,25,1,6),
(188,27,3,8),
(189,14,1,3),
(190,16,2,8),
(191,25,2,4),
(192,10,2,8),
(193,20,2,7),
(194,23,2,6),
(195,19,1,9),
(196,7,3,5),
(197,28,2,5),
(198,24,1,10),
(199,10,2,9),
(200,4,1,10);


-- Asistencias
INSERT INTO asistencias (estudiante_id, asignacion_id, fecha_asistencia, presente)
VALUES
(1,3,'2025-07-18',True),
(2, 16, '2025-07-22', False),
(3, 28, '2025-07-29', False),
(4, 25, '2025-07-25', True),
(5, 7, '2025-07-28', False),
(6, 29, '2025-07-31', True),
(7, 3, '2025-07-27', False),
(8, 17, '2025-07-20', False),
(9, 10, '2025-07-28', False),
(10, 4, '2025-07-29', True),
(11, 22, '2025-07-18', False),
(12, 26, '2025-07-26', False),
(13, 27, '2025-07-27', False),
(14, 14, '2025-07-20', False),
(15, 4, '2025-07-25', False),
(16, 16, '2025-07-17', False),
(17, 5, '2025-07-17', False),
(18, 22, '2025-07-25', False),
(19, 18, '2025-07-27', False),
(20, 6, '2025-07-23', True),
(21, 6, '2025-07-23', True),
(22, 29, '2025-07-24', True),
(23, 23, '2025-07-31', True),
(24, 16, '2025-07-20', False),
(25, 29, '2025-07-21', False),
(26, 10, '2025-07-29', True),
(27, 11, '2025-07-22', False),
(28, 25, '2025-07-28', False),
(29, 9, '2025-07-29', True),
(30, 1, '2025-07-18', False),
(31, 21, '2025-07-30', False),
(32, 15, '2025-07-25', True),
(33, 17, '2025-07-31', False),
(34, 27, '2025-07-31', False),
(35, 17, '2025-07-28', False),
(36, 10, '2025-07-17', False),
(37, 4, '2025-07-23', False),
(38, 23, '2025-07-22', True),
(39, 15, '2025-07-23', False),
(40, 13, '2025-07-26', False),
(41, 18, '2025-07-25', False),
(42, 13, '2025-07-17', False),
(43, 9, '2025-07-21', False),
(44, 9, '2025-07-31', True),
(45, 27, '2025-07-24', True),
(46, 27, '2025-07-29', False),
(47, 20, '2025-07-27', False),
(48, 1, '2025-07-21', False),
(49, 30, '2025-07-29', True),
(50, 9, '2025-07-19', False),
(51, 10, '2025-07-20', False),
(52, 5, '2025-07-17', True),
(53, 9, '2025-07-23', True),
(54, 16, '2025-07-21', True),
(55, 17, '2025-07-26', False),
(56, 19, '2025-07-21', True),
(57, 19, '2025-07-24', True),
(58, 21, '2025-07-18', False),
(59, 20, '2025-07-18', False),
(60, 21, '2025-07-25', False),
(61, 8, '2025-07-31', False),
(62, 26, '2025-07-24', True),
(63, 20, '2025-07-25', False),
(64, 29, '2025-07-17', False),
(65, 15, '2025-07-19', True),
(66, 2, '2025-07-29', False),
(67, 14, '2025-07-21', False),
(68, 5, '2025-07-19', False),
(69, 9, '2025-07-22', True),
(70, 6, '2025-07-29', True),
(71, 12, '2025-07-23', True),
(72, 25, '2025-07-20', True),
(73, 16, '2025-07-28', False),
(74, 24, '2025-07-19', True),
(75, 13, '2025-07-17', False),
(76, 7, '2025-07-31', False),
(77, 11, '2025-07-24', False),
(78, 15, '2025-07-18', False),
(79, 17, '2025-07-20', False),
(80, 16, '2025-07-31', False),
(81, 19, '2025-07-28', False),
(82, 7, '2025-07-19', False),
(83, 25, '2025-07-30', False),
(84, 24, '2025-07-31', True),
(85, 23, '2025-07-22', True),
(86, 4, '2025-07-24', True),
(87, 17, '2025-07-29', True),
(88, 11, '2025-07-21', True),
(89, 25, '2025-07-27', False),
(90, 26, '2025-07-25', False),
(91, 2, '2025-07-24', False),
(92, 3, '2025-07-18', True),
(93, 27, '2025-07-31', False),
(94, 3, '2025-07-21', True),
(95, 19, '2025-07-21', False),
(96, 2, '2025-07-22', False),
(97, 9, '2025-07-26', False),
(98, 19, '2025-07-25', False),
(99, 16, '2025-07-24', True),
(100, 15, '2025-07-26', False),
(101, 8, '2025-07-27', False),
(102, 14, '2025-07-21', False),
(103, 17, '2025-07-31', False),
(104, 19, '2025-07-29', True),
(105, 13, '2025-07-21', True),
(106, 25, '2025-07-27', True),
(107, 7, '2025-07-27', True),
(108, 27, '2025-07-26', False),
(109, 12, '2025-07-21', True),
(110, 16, '2025-07-19', True),
(111, 11, '2025-07-23', False),
(112, 13, '2025-07-18', False),
(113, 28, '2025-07-19', False),
(114, 16, '2025-07-29', False),
(115, 13, '2025-07-18', True),
(116, 3, '2025-07-18', True),
(117, 5, '2025-07-24', False),
(118, 22, '2025-07-25', False),
(119, 14, '2025-07-26', True),
(120, 29, '2025-07-25', False),
(121, 8, '2025-07-30', True),
(122, 16, '2025-07-21', True),
(123, 13, '2025-07-18', False),
(124, 17, '2025-07-25', True),
(125, 10, '2025-07-28', False),
(126, 5, '2025-07-20', True),
(127, 10, '2025-07-24', True),
(128, 23, '2025-07-24', False),
(129, 28, '2025-07-31', True),
(130, 10, '2025-07-28', True),
(131, 20, '2025-07-19', True),
(132, 11, '2025-07-27', False),
(133, 3, '2025-07-31', False),
(134, 9, '2025-07-25', True),
(135, 2, '2025-07-31', True),
(136, 25, '2025-07-18', False),
(137, 14, '2025-07-17', False),
(138, 23, '2025-07-31', True),
(139, 11, '2025-07-22', False),
(140, 22, '2025-07-19', True),
(141, 20, '2025-07-26', True),
(142, 29, '2025-07-29', False),
(143, 19, '2025-07-30', True),
(144, 4, '2025-07-21', False),
(145, 2, '2025-07-20', True),
(146, 3, '2025-07-28', False),
(147, 2, '2025-07-31', True),
(148, 22, '2025-07-22', True),
(149, 26, '2025-07-24', True),
(150, 11, '2025-07-26', True),
(151, 24, '2025-07-18', True),
(152, 5, '2025-07-18', False),
(153, 4, '2025-07-27', False),
(154, 18, '2025-07-31', True),
(155, 13, '2025-07-17', True),
(156, 26, '2025-07-30', True),
(157, 6, '2025-07-27', False),
(158, 6, '2025-07-31', True),
(159, 8, '2025-07-24', False),
(160, 29, '2025-07-28', True),
(161, 21, '2025-07-28', False),
(162, 19, '2025-07-29', False),
(163, 2, '2025-07-24', True),
(164, 18, '2025-07-23', True),
(165, 25, '2025-07-17', True),
(166, 2, '2025-07-19', False),
(167, 29, '2025-07-19', True),
(168, 6, '2025-07-26', False),
(169, 11, '2025-07-31', True),
(170, 6, '2025-07-18', False),
(171, 14, '2025-07-29', False),
(172, 20, '2025-07-31', True),
(173, 4, '2025-07-17', True),
(174, 1, '2025-07-22', True),
(175, 15, '2025-07-22', True),
(176, 13, '2025-07-25', False),
(177, 21, '2025-07-31', False),
(178, 16, '2025-07-20', True),
(179, 28, '2025-07-19', False),
(180, 1, '2025-07-17', True),
(181, 23, '2025-07-19', False),
(182, 11, '2025-07-22', False),
(183, 16, '2025-07-18', False),
(184, 3, '2025-07-22', False),
(185, 4, '2025-07-22', False),
(186, 24, '2025-07-30', True),
(187, 23, '2025-07-25', True),
(188, 26, '2025-07-25', False),
(189, 2, '2025-07-24', False),
(190, 10, '2025-07-24', True),
(191, 20, '2025-07-30', False),
(192, 27, '2025-07-21', False),
(193, 11, '2025-07-30', True),
(194, 25, '2025-07-18', False),
(195, 13, '2025-07-29', True),
(196, 9, '2025-07-29', True),
(197, 9, '2025-07-19', False),
(198, 14, '2025-07-20', False),
(199, 21, '2025-07-27', True),
(200, 19, '2025-07-30', False);




-- PROCEDIMIENTOS---------------------------------------------------------------- 
-- 1. AGREGAR UN NUEVO REPRESENTANTE
delimiter //
CREATE PROCEDURE insertarNuevo_representante(
    IN p_nombres VARCHAR(100),
    IN p_apellidos VARCHAR(100),
    IN p_telefono VARCHAR(15),
    IN p_correo VARCHAR(100)
)
BEGIN
    -- Insertar el nuevo representante en la tabla 'representantes'
    INSERT INTO representantes (nombres, apellidos, telefono, correo)
    VALUES (p_nombres, p_apellidos, p_telefono, p_correo);
END //
delimiter ;


-- 2. AÑADIR UN NUEVO ESTUDIANTE
delimiter //
CREATE PROCEDURE insertar_estudiante(
    IN p_cedula VARCHAR(10),
    IN p_genero_id INT,
    IN p_nombres VARCHAR(100),
    IN p_apellidos VARCHAR(100),
    IN p_fecha_nacimiento DATE,
    IN p_direccion TEXT,
    IN p_telefono VARCHAR(15),
    IN p_correo VARCHAR(100),
    IN p_representante_id INT
)
BEGIN
    INSERT INTO estudiantes (cedula, genero_id, nombres, apellidos, fecha_nacimiento, direccion, telefono, correo, representante_id)
    VALUES (p_cedula, p_genero_id, p_nombres, p_apellidos, p_fecha_nacimiento, p_direccion, p_telefono, p_correo, p_representante_id);
END //
delimiter ;


-- 3. modificar una calificacion
DELIMITER //
CREATE PROCEDURE modificar_calificacion(
    IN p_calificacion_id INT,  -- Cambié el nombre del parámetro a 'p_calificacion_id'
    IN nueva_nota DECIMAL(5,2)
)
BEGIN
    UPDATE calificaciones
    SET nota = nueva_nota
    WHERE calificacion_id = p_calificacion_id;  -- Usamos 'p_calificacion_id' aquí
END //
DELIMITER ;


-- 4. matricular un estudiante 
delimiter //
CREATE PROCEDURE matricular_estudiante(
    IN p_estudiante_id INT,
    IN p_paralelo_id INT,
    IN p_fecha_matricula DATE,
    IN p_estado_id INT
)
BEGIN
    INSERT INTO matriculas (estudiante_id, paralelo_id, fecha_matricula, estado_id)
    VALUES (p_estudiante_id, p_paralelo_id, CURDATE(), p_estado_id);
END //
delimiter ;


-- 5. Eliminar Estudiante
DELIMITER //
CREATE PROCEDURE eliminar_estudiante(IN id_estudiante VARCHAR(10))
BEGIN
    DELETE FROM estudiantes WHERE estudiante_id = id_estudiante;
END //
DELIMITER ;


-- FUNCIONES-------------------------------------------------------------------------

-- 1. OBTNER EL ESTADO DE MATRICULA DE UN ESTUDIANTE
DELIMITER //
CREATE FUNCTION obtener_estado_matricula(estudiante_id INT)
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    DECLARE estado VARCHAR(30);
    SELECT sm.descripcion INTO estado
    FROM matriculas m
    JOIN estados_matricula sm ON m.estado_id = sm.estado_id
    WHERE m.estudiante_id = estudiante_id ORDER BY m.fecha_matricula DESC LIMIT 1;
    RETURN estado;
END //
DELIMITER ;

-- 2. CONTAR CUANTOS ESTUDIANTES HAY EN UN PARALELO
DELIMITER //
CREATE FUNCTION contar_estudiantes_paralelo(f_paralelo_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM matriculas
    WHERE paralelo_id = f_paralelo_id;
    RETURN total;
END //
DELIMITER ;


-- 3. cantidad de estudiantes por genero
DELIMITER //

CREATE FUNCTION contar_estudiantes_genero(p_genero_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    
    -- Contamos la cantidad de estudiantes según el género
    SELECT COUNT(*) INTO total
    FROM estudiantes
    WHERE genero_id = p_genero_id;

    -- Devolvemos el total
    RETURN total;
END //

DELIMITER ;

-- 4. funcion poara obtener docentes asignados a una meteria en especifico

DELIMITER //
CREATE FUNCTION contar_docentes_materia(p_materia_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM asignacion_materias
    WHERE materia_id = p_materia_id;
    -- Devolvemos el total
    RETURN total;
END //
DELIMITER ;


-- 5. funcion para verificar si un docente tiene un correo registrado
DELIMITER //

CREATE FUNCTION tiene_correo_docente(docente_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE tiene_correo INT;

    -- Verificamos si el docente tiene correo registrado
    SELECT COUNT(*) INTO tiene_correo
    FROM docentes
    WHERE docente_id = docente_id AND correo IS NOT NULL;

    -- Devolvemos 1 si tiene correo, 0 si no tiene
    RETURN IF(tiene_correo > 0, 1, 0);
END //

DELIMITER ;


-- JOINS ----------------------------------------------------------------------------
-- 1. Listar todos los estudiantes con el nombre de la materia, docente y horario
SELECT 
    e.nombres AS estudiante,
    e.apellidos AS apellido_estudiante,
    m.nombre AS materia,
    d.nombre AS docente,
    d.apellidos AS apellido_docente,
    h.dia AS dia_clase,
    h.hora_inicio,
    h.hora_fin
FROM matriculas ma
JOIN estudiantes e ON ma.estudiante_id = e.estudiante_id
JOIN paralelos p ON ma.paralelo_id = p.paralelo_id
JOIN asignacion_materias am ON p.paralelo_id = am.paralelo_id
JOIN materias m ON am.materia_id = m.materia_id
JOIN docentes d ON am.docente_id = d.docente_id
JOIN horarios h ON am.horario_id = h.horario_id;

-- 2. listar a los estudaintes con su calificacion del primer bimestre
SELECT 
    e.nombres AS estudiante,
    e.apellidos AS apellido_estudiante,
    m.nombre AS materia,
    c.trimestre,
    c.nota
FROM calificaciones c
JOIN estudiantes e ON c.estudiante_id = e.estudiante_id
JOIN asignacion_materias am ON c.asignacion_id = am.asignacion_id
JOIN materias m ON am.materia_id = m.materia_id
WHERE c.trimestre = 1;



-- 3. Obtener los docentes que imparten clases en un paralelo específico
SELECT 
    d.nombre AS docente,
    d.apellidos AS apellido_docente,
    m.nombre AS materia,
    p.nombre_paralelo
FROM asignacion_materias am
JOIN docentes d ON am.docente_id = d.docente_id
JOIN materias m ON am.materia_id = m.materia_id
JOIN paralelos p ON am.paralelo_id = p.paralelo_id
WHERE p.nombre_paralelo = 'A';


-- 4. Obtener la cantidad de estudiantes por estado de matrícula
SELECT 
    em.descripcion AS estado_matricula,
    COUNT(e.estudiante_id) AS total_estudiantes
FROM matriculas ma
JOIN estudiantes e ON ma.estudiante_id = e.estudiante_id
JOIN estados_matricula em ON ma.estado_id = em.estado_id
GROUP BY em.descripcion;


-- 5. Obtener el total de horas semanales por materia en cada paralelo

SELECT 
    p.nombre_paralelo,
    m.nombre AS materia,
    SUM(h.hora_fin - h.hora_inicio) AS total_horas_semanales
FROM asignacion_materias am
JOIN materias m ON am.materia_id = m.materia_id
JOIN paralelos p ON am.paralelo_id = p.paralelo_id
JOIN horarios h ON am.horario_id = h.horario_id
GROUP BY p.nombre_paralelo, m.nombre;



-- TRIGGERS

-- Tabla única de logs para auditoría y control
CREATE TABLE log_acciones (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_accion VARCHAR(50),        
    tabla_afectada VARCHAR(50),     
    registro_id INT,               
    descripcion TEXT,               
    usuario VARCHAR(100),        
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
-- Trigger para INSERT en estudiantes
CREATE TRIGGER trg_insert_estudiante_log
AFTER INSERT ON estudiantes
FOR EACH ROW
BEGIN
    INSERT INTO log_acciones (tipo_accion, tabla_afectada, registro_id, descripcion, usuario)
    VALUES ('INSERT', 'estudiantes', NEW.estudiante_id, CONCAT('Estudiante ', NEW.nombres, ' ', NEW.apellidos, ' creado.'), USER());
END;
//

DELIMITER //
-- Trigger para UPDATE en calificaciones
CREATE TRIGGER trg_update_calificacion_log
AFTER UPDATE ON calificaciones
FOR EACH ROW
BEGIN
    INSERT INTO log_acciones (tipo_accion, tabla_afectada, registro_id, descripcion, usuario)
    VALUES ('UPDATE', 'calificaciones', NEW.calificacion_id,
            CONCAT('Nota cambiada de ', OLD.nota, ' a ', NEW.nota), USER());
END;
//

DELIMITER //
-- Trigger para DELETE en estudiantes
CREATE TRIGGER trg_delete_estudiante_log
BEFORE DELETE ON estudiantes
FOR EACH ROW
BEGIN
    INSERT INTO log_acciones (tipo_accion, tabla_afectada, registro_id, descripcion, usuario)
    VALUES ('DELETE', 'estudiantes', OLD.estudiante_id, CONCAT('Estudiante ', OLD.nombres, ' ', OLD.apellidos, ' eliminado.'), USER());
END;
//


SHOW TRIGGERS FROM educacion;

-- INDICES
-- Índices simples en claves foráneas
CREATE INDEX idx_estudiante_id ON calificaciones(estudiante_id);
CREATE INDEX idx_asignacion_id ON calificaciones(asignacion_id);

CREATE INDEX idx_matricula_estudiante ON matriculas(estudiante_id);
CREATE INDEX idx_matricula_paralelo ON matriculas(paralelo_id);

-- Índice simple para búsquedas por correo
CREATE INDEX idx_representante_correo ON representantes(correo);

-- Índice para ordenamiento por apellido
CREATE INDEX idx_estudiante_apellidos ON estudiantes(apellidos);

-- Consultas frecuentes por estudiante y asignatura
CREATE INDEX idx_calificaciones_est_asig ON calificaciones(estudiante_id, asignacion_id);

-- Consultas por paralelo y estado de matrícula
CREATE INDEX idx_matriculas_paralelo_estado ON matriculas(paralelo_id, estado_id);



EXPLAIN
SELECT 
    e.estudiante_id,
    CONCAT(e.nombres, ' ', e.apellidos) AS estudiante,
    p.nombre_paralelo,
    m.nombre AS materia,
    c.trimestre,
    c.nota
FROM calificaciones c
JOIN estudiantes e ON e.estudiante_id = c.estudiante_id
JOIN asignacion_materias am ON am.asignacion_id = c.asignacion_id
JOIN materias m ON m.materia_id = am.materia_id
JOIN paralelos p ON p.paralelo_id = am.paralelo_id
WHERE e.nombres = 'Tina' AND e.apellidos = 'Medina'
  AND p.nombre_paralelo = 'B' AND p.grado = 'Quinto'
ORDER BY m.nombre, c.trimestre;


