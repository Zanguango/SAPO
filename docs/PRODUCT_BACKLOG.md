# S.A.P.O. — Product Backlog

**Proyecto:** Sistema Avanzado Policial Operativo  
**Asignatura:** Proyecto de Ingeniería de Software (47GIIN) — VIU  
**Autor:** Ignacio Teruel Cuartero  
**Repositorio:** [Zanguango/SAPO](https://github.com/Zanguango/SAPO)  
**Tablero:** [SAPO – Gestión del proyecto](https://github.com/users/Zanguango/projects/1)  
**Versión:** 1.1 — 17 de noviembre de 2026

> **Naturaleza del proyecto.** S.A.P.O. es un prototipo académico de un escenario simulado y utiliza exclusivamente datos ficticios. No se conecta con sistemas policiales, judiciales ni administrativos reales. «Avanzado» alude a la integración funcional, no a inteligencia artificial ni a capacidades predictivas. El resultado es un prototipo en entorno de desarrollo o demostración, no un sistema de producción.

## 1. Visión del producto

Integrar información ficticia de personas e incidencias para facilitar el registro y consulta de actuaciones en un entorno académico controlado, con persistencia relacional, validaciones y autenticación con permisos básicos.

## 2. Alcance comprometido para la asignatura

La implementación práctica se concentra en aproximadamente el 20 % del producto: **un único circuito operativo para registrar y consultar incidencias asociadas a personas ficticias**. El incremento contempla las operaciones necesarias sobre personas e incidencias, su asociación, persistencia PostgreSQL, validaciones y autenticación básica con al menos dos perfiles de prueba y comprobación de permisos. La consulta de antecedentes solo se incorporará si resulta necesaria para completar el circuito. Los demás módulos son visión global de producto, pero no compromiso de implementación en esta entrega.

**Dentro del incremento:** estructura y arquitectura, conexión de la API a PostgreSQL, alta/listado/consulta/modificación de personas, alta/listado/consulta/cambio de estado de incidencias, asociación entre personas e incidencias, autenticación y permisos básicos, pruebas, documentación y seguridad básica.

**Visión futura:** archivo de personas; gestión completa de antecedentes; organización y unidades; detección y avisos automatizados; informes y estadísticas avanzadas; auditoría avanzada; administración completa de usuarios y perfiles; filtros avanzados; y procedimientos completos de copia y recuperación.

## 3. Convenciones de priorización

| Prioridad | Significado |
|---|---|
| Alta | Necesaria para el incremento práctico o sus controles esenciales. |
| Media | Apoyo o calidad del incremento; se ejecuta según necesidad y capacidad. |
| Baja | Elemento de visión futura, sin compromiso de implementación actual. |

| Alcance | Significado |
|---|---|
| Incremento | Parte del compromiso práctico. |
| Incremento condicionado | Solo se incorpora si se justifica como necesario para el circuito principal. |
| Futuro | Se conserva en la visión del producto, pero no se compromete en el incremento actual. |

La prioridad y el alcance son atributos distintos: un elemento puede tener prioridad **Baja** y alcance **Futuro**. Los campos correspondientes de GitHub Projects deben reflejar esta distinción.

## 4. Resumen del Product Backlog

| ID | Elemento | Prioridad | Alcance |
|---|---|---|---|
| SAPO-001 | Preparar repositorio, estructura y arquitectura del proyecto | Alta | Incremento |
| SAPO-002 | Configurar conexión del backend con PostgreSQL | Alta | Incremento |
| SAPO-003 | Definir el esquema de persistencia necesario para personas e incidencias | Alta | Incremento |
| SAPO-004 | Implementar inicio de sesión | Alta | Incremento |
| SAPO-005 | Aplicar permisos básicos según perfil | Alta | Incremento |
| SAPO-006 | Registrar una persona ficticia | Alta | Incremento |
| SAPO-007 | Listar, consultar y buscar personas por identificador | Alta | Incremento |
| SAPO-008 | Actualizar los datos permitidos de una persona | Alta | Incremento |
| SAPO-009 | Archivar una persona | Baja | Futuro |
| SAPO-010 | Consultar antecedentes ficticios asociados a una persona, si el flujo lo requiere | Media | Incremento condicionado |
| SAPO-011 | Gestionar antecedentes mediante operaciones completas | Baja | Futuro |
| SAPO-012 | Registrar una incidencia ficticia | Alta | Incremento |
| SAPO-013 | Asociar una o varias personas a una incidencia | Alta | Incremento |
| SAPO-014 | Listar y consultar incidencias | Alta | Incremento |
| SAPO-015 | Actualizar el estado de una incidencia | Alta | Incremento |
| SAPO-016 | Mostrar la ficha integrada de una incidencia y sus personas relacionadas | Media | Incremento |
| SAPO-017 | Gestionar organización y unidades | Baja | Futuro |
| SAPO-018 | Detectar incidencias pendientes de revisión | Baja | Futuro |
| SAPO-019 | Generar avisos de seguimiento sin duplicados | Baja | Futuro |
| SAPO-020 | Generar informes de incidencias por periodo y estado | Baja | Futuro |
| SAPO-021 | Generar informes de actividad por tipo | Baja | Futuro |
| SAPO-022 | Consultar estadísticas agregadas | Baja | Futuro |
| SAPO-023 | Registrar eventos de auditoría | Baja | Futuro |
| SAPO-024 | Consultar el histórico de auditoría | Baja | Futuro |
| SAPO-025 | Administrar usuarios y perfiles | Baja | Futuro |
| SAPO-026 | Incorporar filtros avanzados de búsqueda | Baja | Futuro |
| SAPO-027 | Verificar el flujo mediante pruebas funcionales y de integración | Alta | Incremento |
| SAPO-028 | Documentar instalación, configuración y uso del prototipo | Media | Incremento |
| SAPO-029 | Definir procedimientos completos de copia y recuperación | Baja | Futuro |
| SAPO-030 | Revisar seguridad, privacidad y tratamiento de datos ficticios | Alta | Incremento |

**Total: 30 elementos.** La asignación a una iteración se gestiona en GitHub Projects y no cambia la pertenencia del elemento al Product Backlog.

## 5. Historias de usuario y criterios de aceptación

Los criterios siguientes expresan condiciones observables para considerar aceptado cada elemento cuando se planifique y ejecute. En los elementos futuros son una definición preliminar del resultado esperado; no implican que deban implementarse en el incremento actual.

### SAPO-001 — Preparar repositorio, estructura y arquitectura del proyecto

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como responsable del desarrollo, quiero organizar el repositorio y definir su arquitectura inicial, para construir el prototipo sobre una base mantenible.

**Criterios de aceptación:**
- Existe una estructura de carpetas para documentación, frontend, backend y base de datos, aunque no incluya lógica funcional.
- El README describe el proyecto, tecnologías, alcance y forma de trabajo.
- La arquitectura identifica interfaz web, API REST y persistencia, con sus responsabilidades.

### SAPO-002 — Configurar conexión del backend con PostgreSQL

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como desarrollador, quiero conectar la API Node.js/Express con PostgreSQL, para persistir y consultar los datos del prototipo.

**Criterios de aceptación:**
- El backend conecta con `sapo_db` usando configuración por variables de entorno.
- Se realiza una consulta de prueba y se gestiona de forma controlada la pérdida de conexión.
- No se guardan credenciales reales en el repositorio ni se muestran en errores.

### SAPO-003 — Definir el esquema de persistencia necesario para personas e incidencias

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como analista/desarrollador, quiero definir las entidades y relaciones del circuito, para asegurar que la base de datos responde al alcance práctico.

**Criterios de aceptación:**
- Se identifican las tablas y campos necesarios para personas, incidencias, usuarios/perfiles y sus relaciones.
- Se documentan claves, cardinalidades y restricciones.
- Se diferencia el modelo necesario para el incremento de las entidades de módulos futuros.

### SAPO-004 — Implementar inicio de sesión

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario de prueba, quiero iniciar sesión con mis credenciales, para acceder al prototipo de forma autenticada.

**Criterios de aceptación:**
- Un usuario de prueba válido puede autenticarse.
- Las credenciales inválidas no permiten acceder y generan una respuesta controlada.
- Las contraseñas no se almacenan en texto plano y las rutas protegidas exigen autenticación.

### SAPO-005 — Aplicar permisos básicos según perfil

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario de prueba, quiero disponer de permisos según mi perfil, para limitar el acceso a operaciones autorizadas.

**Criterios de aceptación:**
- Existen al menos dos perfiles de prueba con permisos diferenciados.
- Los permisos se comprueban en el servidor para cada operación protegida.
- Un perfil sin permiso no puede ejecutar la operación y recibe acceso denegado.

### SAPO-006 — Registrar una persona ficticia

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autorizado, quiero registrar una persona ficticia, para disponer de sus datos para asociarla a incidencias.

**Criterios de aceptación:**
- Se puede registrar una persona con los campos obligatorios definidos.
- Los datos se validan antes de persistirse.
- La persona se guarda y se evita duplicar su identificador único.

### SAPO-007 — Listar, consultar y buscar personas por identificador

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autorizado, quiero listar personas y buscar una por identificador, para localizar un registro ficticio.

**Criterios de aceptación:**
- Se obtiene un listado de personas con campos permitidos.
- Se puede consultar por identificador único.
- Una búsqueda sin coincidencias devuelve un resultado vacío controlado.

### SAPO-008 — Actualizar los datos permitidos de una persona

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autorizado, quiero modificar los datos editables de una persona, para mantener actualizado el registro.

**Criterios de aceptación:**
- Se modifican únicamente los campos autorizados.
- Los cambios se validan y persisten en PostgreSQL.
- El identificador único y los campos no editables no pueden alterarse.

### SAPO-009 — Archivar una persona

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como usuario gestor, quiero archivar una persona, para conservar su información sin eliminarla físicamente.

**Criterios de aceptación:**
- Solo perfiles autorizados pueden archivar.
- El archivo marca el registro como inactivo sin borrar sus datos.
- Las consultas ordinarias distinguen registros archivados y se conservan sus relaciones.

### SAPO-010 — Consultar antecedentes ficticios asociados a una persona, si el flujo lo requiere

**Prioridad:** Media  
**Alcance:** Incremento condicionado

**Historia de usuario:** Como usuario autorizado, quiero consultar antecedentes ficticios de una persona cuando sean necesarios, para aportar contexto al circuito de incidencias.

**Criterios de aceptación:**
- La consulta solo se incorpora si se justifica como necesaria para el circuito principal.
- Los antecedentes consultados son ficticios y están vinculados a la persona seleccionada.
- La consulta es de solo lectura y gestiona correctamente la ausencia de resultados.

### SAPO-011 — Gestionar antecedentes mediante operaciones completas

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como usuario gestor, quiero crear, consultar, modificar y archivar antecedentes, para gestionar el módulo completo de antecedentes.

**Criterios de aceptación:**
- Se definen operaciones de alta, consulta, modificación y archivo.
- Las operaciones validan datos y mantienen relaciones con personas.
- El módulo queda fuera del incremento práctico actual.

### SAPO-012 — Registrar una incidencia ficticia

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autorizado, quiero registrar una incidencia ficticia, para iniciar el circuito operativo principal.

**Criterios de aceptación:**
- Se crea una incidencia con los campos obligatorios definidos.
- Los campos y valores se validan antes de persistir.
- Se guarda con identificador único y estado inicial definido.

### SAPO-013 — Asociar una o varias personas a una incidencia

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autorizado, quiero asociar personas ficticias a una incidencia, para reflejar quién está relacionado con el hecho.

**Criterios de aceptación:**
- Una incidencia puede asociarse a una o varias personas existentes.
- La relación queda persistida y se recupera al consultar la incidencia.
- Se evitan relaciones duplicadas y referencias a personas inexistentes.

### SAPO-014 — Listar y consultar incidencias

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autorizado, quiero listar incidencias y consultar su detalle, para realizar el seguimiento operativo.

**Criterios de aceptación:**
- Se obtiene un listado con información resumida autorizada.
- Se consulta el detalle mediante identificador.
- Las incidencias inexistentes o no accesibles producen una respuesta controlada.

### SAPO-015 — Actualizar el estado de una incidencia

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autorizado, quiero cambiar el estado de una incidencia, para reflejar su evolución.

**Criterios de aceptación:**
- Los perfiles autorizados pueden cambiar el estado de una incidencia existente.
- Solo se aceptan estados y transiciones definidos.
- El nuevo estado persiste y las transiciones no permitidas se rechazan.

### SAPO-016 — Mostrar la ficha integrada de una incidencia y sus personas relacionadas

**Prioridad:** Media  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autorizado, quiero consultar una ficha integrada de incidencia y personas, para comprender el registro en una sola consulta.

**Criterios de aceptación:**
- La ficha muestra datos principales, estado y personas relacionadas.
- La información se recupera de los registros persistidos y refleja sus cambios.
- Se respetan permisos y se representa correctamente la ausencia de personas relacionadas.

### SAPO-017 — Gestionar organización y unidades

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como administrador, quiero gestionar la organización y sus unidades, para representar la estructura organizativa completa.

**Criterios de aceptación:**
- Se definen operaciones para registrar, consultar y modificar organización y unidades.
- Las relaciones se mantienen coherentes y se aplican permisos administrativos.
- La funcionalidad queda fuera del incremento práctico actual.

### SAPO-018 — Detectar incidencias pendientes de revisión

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como responsable de seguimiento, quiero identificar incidencias pendientes de revisión, para facilitar el seguimiento.

**Criterios de aceptación:**
- Se define una regla verificable para identificar incidencias pendientes.
- La consulta devuelve únicamente registros que cumplen la regla.
- La detección no modifica los datos y se mantiene como evolución futura.

### SAPO-019 — Generar avisos de seguimiento sin duplicados

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como responsable de seguimiento, quiero recibir avisos cuando una incidencia requiera seguimiento, para evitar omisiones y notificaciones repetidas.

**Criterios de aceptación:**
- Se especifican las condiciones de generación del aviso.
- Se comprueba si existe un aviso equivalente antes de crear otro.
- Los avisos se relacionan con la incidencia y la automatización queda fuera del incremento actual.

### SAPO-020 — Generar informes de incidencias por periodo y estado

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como responsable del sistema, quiero obtener informes por periodo y estado, para analizar la actividad registrada.

**Criterios de aceptación:**
- El informe admite filtros por periodo y estado.
- Los totales y detalles corresponden con los registros y filtros seleccionados.
- El informe se mantiene como módulo futuro.

### SAPO-021 — Generar informes de actividad por tipo

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como responsable del sistema, quiero obtener informes agrupados por tipo de actividad, para conocer la distribución de actividad.

**Criterios de aceptación:**
- Se define el catálogo de tipos de actividad.
- El informe agrupa cantidades por tipo y periodo, con totales verificables.
- La funcionalidad queda fuera del incremento actual.

### SAPO-022 — Consultar estadísticas agregadas

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como responsable del sistema, quiero consultar indicadores agregados, para obtener una visión resumida de la actividad.

**Criterios de aceptación:**
- Se documentan indicadores, fórmulas y origen de datos.
- Los valores se calculan con datos persistidos y filtros explícitos.
- Se evita exponer datos individuales innecesarios y se considera evolución futura.

### SAPO-023 — Registrar eventos de auditoría

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como administrador, quiero registrar eventos relevantes de uso y modificación, para disponer de trazabilidad.

**Criterios de aceptación:**
- Se definen eventos y datos mínimos a registrar.
- Los eventos se almacenan estructurados y asociados a usuario y momento cuando proceda.
- No se registran contraseñas ni secretos; la auditoría avanzada queda fuera del incremento.

### SAPO-024 — Consultar el histórico de auditoría

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como administrador autorizado, quiero consultar el histórico de auditoría, para revisar las operaciones registradas.

**Criterios de aceptación:**
- El histórico admite criterios de consulta como periodo, usuario o tipo.
- Los resultados muestran los datos mínimos del evento según permisos.
- Los perfiles no autorizados no pueden consultar el histórico.

### SAPO-025 — Administrar usuarios y perfiles

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como administrador, quiero gestionar usuarios y perfiles, para administrar las cuentas del producto completo.

**Criterios de aceptación:**
- Se definen operaciones para crear, consultar, modificar y desactivar usuarios y perfiles.
- Se aplican restricciones para evitar asignaciones inválidas o ausencia de administrador.
- La administración completa queda como visión futura; el incremento requiere solo perfiles de prueba.

### SAPO-026 — Incorporar filtros avanzados de búsqueda

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como usuario autorizado, quiero combinar varios criterios de búsqueda, para localizar registros con precisión.

**Criterios de aceptación:**
- Se documentan criterios combinables y su comportamiento.
- Los filtros se aplican en el servidor y validan los valores recibidos.
- La búsqueda respeta permisos y queda fuera del incremento actual.

### SAPO-027 — Verificar el flujo mediante pruebas funcionales y de integración

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como responsable de calidad/desarrollador, quiero verificar el circuito con pruebas reproducibles, para demostrar que el incremento cumple los requisitos.

**Criterios de aceptación:**
- Se prueban los flujos principales de personas, incidencias, asociación y cambio de estado.
- Se prueban errores relevantes: datos inválidos, identificadores inexistentes y permisos insuficientes.
- Las pruebas de integración verifican persistencia en PostgreSQL y sus resultados quedan documentados.

### SAPO-028 — Documentar instalación, configuración y uso del prototipo

**Prioridad:** Media  
**Alcance:** Incremento

**Historia de usuario:** Como desarrollador/evaluador, quiero disponer de instrucciones para preparar y ejecutar el prototipo, para facilitar su revisión y demostración académica.

**Criterios de aceptación:**
- Se enumeran requisitos previos y versiones tecnológicas.
- Se documentan configuración de PostgreSQL, variables de entorno, dependencias y arranque a medida que estén implementados.
- Se proporciona un ejemplo de configuración sin credenciales reales y pasos reproducibles.

### SAPO-029 — Definir procedimientos completos de copia y recuperación

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como administrador, quiero disponer de procedimientos de copia y recuperación, para preservar la información ante fallos.

**Criterios de aceptación:**
- Se documentan frecuencia, alcance y ubicación prevista de copias.
- Se describen pasos de recuperación y comprobaciones posteriores.
- La operación completa y automatización quedan fuera del incremento actual.

### SAPO-030 — Revisar seguridad, privacidad y tratamiento de datos ficticios

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como responsable del proyecto, quiero aplicar criterios básicos de seguridad y privacidad, para evitar exposición de secretos y preservar el carácter académico.

**Criterios de aceptación:**
- Se utilizan exclusivamente datos ficticios; no hay conexiones a sistemas institucionales reales.
- Las credenciales y secretos se excluyen del código y del control de versiones.
- Se documentan autenticación, permisos, validación de entradas, errores y limitación de uso fuera de producción.

## 6. Desglose técnico orientativo

1. Estructura del repositorio, arquitectura y documentación inicial.
2. Revisión del modelo de datos y preparación de PostgreSQL ya disponible.
3. Configuración de variables de entorno y conexión de Node.js/Express con PostgreSQL.
4. Implementación de autenticación y permisos básicos.
5. Operaciones de registro y consulta de personas ficticias.
6. Operaciones de registro y consulta de incidencias ficticias.
7. Asociación de personas con incidencias y actualización de estado.
8. Validaciones de entrada y reglas de negocio.
9. Pruebas funcionales y de integración.
10. Documentación de instalación, configuración y ejecución.
11. Revisión de seguridad básica y tratamiento de datos ficticios.

## 7. Tecnologías y organización

- **Backend:** JavaScript con Node.js y Express para una API REST.
- **Frontend:** HTML, CSS y JavaScript.
- **Persistencia:** PostgreSQL.
- **Arquitectura:** cliente-servidor por capas: interfaz web, API REST y persistencia.
- **Control de versiones:** Git y GitHub.
- **Seguimiento:** GitHub Projects, con estados, prioridad, alcance e iteraciones.
- **Metodología:** Scrum adaptado al trabajo individual (Single Scrum), con planificación, seguimiento, revisión del incremento y retrospectiva.

## 8. Criterios generales de aceptación del incremento

- El sistema utiliza exclusivamente datos ficticios y no se conecta a servicios institucionales reales.
- Las operaciones comprometidas persisten correctamente en PostgreSQL.
- Se puede completar el circuito de registrar una incidencia, asociarla a una o varias personas y consultarla o actualizar su estado.
- Las operaciones de personas permiten registrar, listar, consultar y modificar los datos autorizados.
- Existen inicio de sesión y al menos dos perfiles de prueba con permisos diferenciados.
- Las entradas se validan y los errores se gestionan sin dejar datos inconsistentes.
- Las pruebas verifican los flujos principales y casos de error.
- La documentación permite configurar y ejecutar el prototipo.

## 9. Gestión y trazabilidad

El repositorio contiene el código y la documentación versionada. GitHub Issues representa cada elemento mediante su identificador SAPO; GitHub Projects permite priorizar, clasificar por alcance, reflejar el estado y asignar iteraciones. La planificación de cada sprint concretará tareas, responsable, criterios aplicables y resultados esperados.

- [Repositorio](https://github.com/Zanguango/SAPO)
- [Documento del Product Backlog](https://github.com/Zanguango/SAPO/blob/main/docs/PRODUCT_BACKLOG.md)
- [Tablero de gestión](https://github.com/users/Zanguango/projects/1)

La selección de historias podrá revisarse en la planificación, manteniendo como prioridad el circuito principal y evitando ampliar el alcance sin justificación.
