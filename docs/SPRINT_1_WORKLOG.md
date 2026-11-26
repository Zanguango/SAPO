# Registro de trabajo — Sprint 1

Este registro recoge lo que he preparado antes del sprint y las comprobaciones y entregables que he realizado durante la iteración. Mantengo las fechas reales conocidas. Cuando no tengo una fecha exacta de un trabajo previo, lo identifico como trabajo anterior al sprint sin asignarle una fecha retrospectiva.

## 1. Situación previa al inicio del Sprint 1

Antes de iniciar el Sprint 1 ya había preparado el diseño SQL de S.A.P.O., creado la base local sapo_db y ejecutado un script de definición del esquema. También había trabajado en PostgreSQL y en las funciones, restricciones, relaciones y triggers necesarios para el modelo.

Este trabajo constituye la situación de partida del proyecto. No lo contabilizo como esfuerzo realizado dentro del Sprint 1 ni le asigno fechas ficticias. En la planificación del sprint he incluido la revisión, delimitación y documentación del modelo existente, no la creación original de la base de datos.

## 2. Trabajo realizado durante el Sprint 1

### 26/11/2026 — Estructura, arquitectura y README (SAPO-001)

He revisado el repositorio y he preparado una estructura inicial para backend, frontend, base de datos, pruebas y documentación. He documentado las responsabilidades de las capas de interfaz, API REST, servicios, repositorios y persistencia. También he actualizado el README y he incorporado un .gitignore.

**Evidencia:** [commit a0fe474 — estructura inicial y arquitectura](https://github.com/Zanguango/SAPO/commit/a0fe474a61dae6a9aa9f8aad175941587faa2606).

Documentos:
- [Arquitectura](ARCHITECTURE.md)
- [Estructura del proyecto](PROJECT_STRUCTURE.md)
- [Guía del entorno](ENVIRONMENT.md)

### 26/11/2026 — Revisión del modelo de datos (SAPO-003)

He revisado los ficheros SAPO_CORREGIDO.sql y SAPO_CORREGIDO_REVISION_ESTATICA.sql. Ambos declaran 24 tablas y 31 claves foráneas. En la versión de revisión estática he contado 40 funciones y 42 triggers. Los dos ficheros incluyen diferencias en determinadas funciones y triggers, por lo que he tomado la versión de revisión estática como referencia del análisis.

He documentado las entidades del circuito práctico, las claves y relaciones relevantes, así como las dependencias que deben respetarse para insertar datos relacionados.

**Evidencia:** [commit a87c401 — modelo de datos y dependencias de carga](https://github.com/Zanguango/SAPO/commit/a87c40150b7e558a3374de6cd819b5754cd1f4d1).

Documentos:
- [Modelo de datos del circuito](DATA_MODEL_SPRINT1.md)
- [Estrategia de datos iniciales ficticios](../database/seeds/README.md)

### 26/11/2026 — Comprobación de la base local

He ejecutado una consulta en pgAdmin 4 conectada a sapo_db. He comprobado que el esquema actual es public, que la versión de PostgreSQL es 18.7 (64 bits) y que la base contiene 24 tablas y 31 claves foráneas. Los recuentos de tablas y relaciones coinciden con los del SQL de referencia.

También he comprobado los registros existentes:
- ORGANIZACION: 1.
- TIPO_INCIDENTE: 7.
- ESTADO_INCIDENTE: 4.
- TRANSICION_ESTADO_INCIDENTE: 5.
- PERSONA: 0.
- INCIDENTE: 0.

He observado que la organización y los siete tipos de incidente ya existen en mi base local, aunque no aparecen insertados en los dos ficheros SQL que he revisado. Antes de recrear la base debo identificar el origen de esos registros o preparar una carga versionada equivalente. No he añadido ni duplicado datos en la base durante esta comprobación.

### 26/11/2026 — Documentación de entorno y configuración (SAPO-028)

He documentado la conexión local, la versión de PostgreSQL y el estado de las herramientas. He preparado backend/.env.example con nombres de variables, sin credenciales reales, y he documentado el orden previsto de carga de datos ficticios.

En CMD he comprobado por separado que node, npm y git no se reconocen como comandos. En una segunda captura del 26/11/2026 he ejecutado psql --version y tampoco se reconoce como comando. La línea donde aparecían concatenados varios comandos no permite verificar npm ni Git, por lo que para esos dos conservo la captura anterior en la que se ejecutaron individualmente. Esto puede deberse a que las herramientas no están instaladas o a que sus rutas no están configuradas en PATH. La conexión al servidor PostgreSQL sigue funcionando desde pgAdmin 4. He consultado Help → About y he confirmado pgAdmin 4 versión 9.19 (Desktop).

**Evidencias:** [commit f4ac4d6 — documentación del entorno y checklist](https://github.com/Zanguango/SAPO/commit/f4ac4d601ad51009518fd12b0f1c3b78d9f5977b) y [commit 013d312 — plantilla de configuración](https://github.com/Zanguango/SAPO/commit/013d3124d7beadb9710ef84625a88764574e2c33).

Documentos:
- [Entorno de desarrollo](ENVIRONMENT.md)
- [Plantilla de variables de entorno](../backend/.env.example)

### 26/11/2026 — Seguridad y privacidad (SAPO-030)

He preparado una checklist con el uso exclusivo de datos ficticios, los perfiles y permisos previstos, la validación de entradas, la protección de secretos y las limitaciones del prototipo. Las medidas que requieren código permanecen identificadas como pendientes de implementación.

**Evidencia:** [commit f4ac4d6 — checklist de seguridad](https://github.com/Zanguango/SAPO/commit/f4ac4d601ad51009518fd12b0f1c3b78d9f5977b).

Documento: [Checklist de seguridad y privacidad](SECURITY_CHECKLIST.md).

## 3. Pendiente para completar el Sprint 1

- [x] Ejecutar psql --version y registrar que CMD no reconoce el comando.
- [x] Consultar la versión exacta de pgAdmin en Help → About: pgAdmin 4 versión 9.19.
- [ ] Instalar Node.js/Git y las herramientas cliente de PostgreSQL, o corregir PATH, antes de iniciar el backend en el Sprint 2.
- [ ] Identificar el origen de los registros existentes en ORGANIZACION y TIPO_INCIDENTE para que la base pueda reproducirse desde cero.
- [ ] Comparar columnas, índices, restricciones, funciones y triggers de la instancia local con el SQL de referencia si se necesita certificar equivalencia completa.

## 4. Criterio de registro

Registro las actividades con la fecha en la que he realizado la comprobación o he generado la evidencia. El trabajo SQL que ya existía antes del 19/11/2026 se conserva como antecedente y no se traslada artificialmente al Sprint 1. No asigno fechas retroactivas a commits o tareas.


### 26/11/2026 — Confirmación de versión de pgAdmin (SAPO-028)

He abierto Help → About en pgAdmin y he comprobado que utilizo pgAdmin 4 versión 9.19 en modo Desktop. Con esta captura queda completado el inventario de la versión de pgAdmin. En CMD siguen sin reconocerse node, npm, git y psql; he documentado esta situación como requisito pendiente de instalación o configuración del PATH antes del Sprint 2.




### 26/11/2026 — Revisión del diseño de la base de datos y estado de los datos iniciales

He documentado el diseño de la base de datos que sirve como base de S.A.P.O. El esquema SQL ya estaba preparado y ejecutado en mi entorno antes del inicio del Sprint 1; forma parte del trabajo previo del proyecto. No lo contabilizo como desarrollo realizado dentro de esta iteración.

Durante el Sprint 1 he revisado el modelo para delimitar las entidades del circuito práctico, he contrastado en pgAdmin los recuentos de la instancia local (24 tablas y 31 claves foráneas) y he documentado las relaciones y dependencias que necesitan datos previos.

La consulta de datos muestra una organización y siete tipos de incidente en mi base local. Los siete tipos tienen fecha de creación 17/11/2026 alrededor de las 18:48:43, anterior al inicio del sprint. El origen exacto de la organización y de los tipos queda pendiente de recuperar. No he vuelto a insertarlos ni he recreado la base.

El diseño global y su relación con los requisitos quedan descritos en [docs/DATABASE_DESIGN.md](DATABASE_DESIGN.md). La investigación sobre la procedencia de los registros está en la [tarea técnica #51](https://github.com/Zanguango/SAPO/issues/51).
