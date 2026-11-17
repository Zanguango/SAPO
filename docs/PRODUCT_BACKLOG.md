# S.A.P.O. — Product Backlog

**Proyecto:** Sistema Avanzado Policial Operativo  
**Asignatura:** Proyecto de Ingeniería de Software (47GIIN) — VIU  
**Autor:** Ignacio Teruel Cuartero  
**Repositorio:** [Zanguango/SAPO](https://github.com/Zanguango/SAPO)  
**Tablero:** [SAPO – Gestión del proyecto](https://github.com/users/Zanguango/projects/1)  
**Versión:** 1.1 — 17 de noviembre de 2026  
**Estado:** Backlog inicial priorizado para la planificación y ejecución iterativa.

> **Naturaleza del proyecto.** S.A.P.O. es un prototipo académico para un escenario simulado y utiliza exclusivamente datos ficticios. No se conecta con sistemas policiales, judiciales ni administrativos reales. El término «Avanzado» alude a la integración funcional del producto, no a inteligencia artificial ni a capacidades predictivas. El resultado previsto es un prototipo en entorno de desarrollo o demostración, no un sistema de producción.

## 1. Visión del producto

Integrar información ficticia de personas e incidencias para facilitar el registro y consulta de actuaciones en un entorno académico controlado, con persistencia relacional, validaciones y autenticación con permisos básicos.

## 2. Alcance comprometido para la asignatura

La implementación práctica se concentra en aproximadamente el 20 % del producto: **un único circuito operativo para registrar y consultar incidencias asociadas a personas ficticias**.

El incremento práctico contempla las operaciones estrictamente necesarias sobre personas e incidencias, asociación entre ambas, persistencia en PostgreSQL, validaciones y autenticación básica con al menos dos perfiles de prueba y comprobación de permisos. La consulta básica de antecedentes solo se incorporará si resulta necesaria para completar el circuito. Los demás módulos forman parte de la visión global, pero no constituyen compromiso de implementación en esta entrega.

### 2.1 Dentro del incremento

- Estructura del proyecto, arquitectura y conexión de la API Node.js/Express con PostgreSQL.
- Alta, listado, consulta por identificador y modificación de personas ficticias.
- Consulta de antecedentes ficticios únicamente si el flujo lo requiere.
- Alta, listado, consulta y actualización de estado de incidencias ficticias.
- Asociación de una o varias personas con una incidencia.
- Inicio de sesión, al menos dos perfiles de prueba y control de permisos.
- Validaciones, persistencia, pruebas funcionales y de integración, documentación y controles básicos de seguridad.

### 2.2 Visión futura (no comprometida para este incremento)

Archivo de personas; gestión completa de antecedentes; organización y unidades; detección y avisos automatizados de seguimiento; informes y estadísticas avanzadas; auditoría avanzada; administración completa de usuarios y perfiles; filtros avanzados; y procedimientos completos de copia y recuperación.

## 3. Convenciones de priorización

| Prioridad | Significado |
|---|---|
| Alta | Necesaria para el incremento práctico o para sus controles esenciales. |
| Media | Apoyo o calidad del incremento; su ejecución se condiciona a la necesidad y capacidad disponible. |
| Baja | Elemento de visión futura, sin compromiso de implementación en el incremento actual. |

| Alcance | Significado |
|---|---|
| Incremento | Forma parte del compromiso práctico de la asignatura. |
| Incremento condicionado | Solo se incorpora si se justifica como necesario para el circuito principal. |
| Futuro | Se conserva en la visión de producto, pero no se compromete en el incremento actual. |

La prioridad y el alcance son atributos distintos: un elemento puede tener prioridad Baja y alcance Futuro. Los valores del tablero GitHub Projects deben coincidir con estas convenciones.

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

**Total: 30 elementos.** Este listado constituye el backlog del producto. La asignación a una iteración concreta se gestiona en GitHub Projects y no cambia la pertenencia del elemento al backlog.

## 5. Historias de usuario y criterios de aceptación

Los criterios siguientes expresan condiciones observables para considerar aceptado cada elemento cuando se planifique y ejecute. En los elementos futuros sirven como definición preliminar del resultado esperado; no implican que deban implementarse en el incremento actual.

### SAPO-001 — Preparar repositorio, estructura y arquitectura del proyecto

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como responsable del desarrollo, quiero organizar el repositorio, definir su estructura y documentar la arquitectura inicial, para disponer de una base ordenada y mantenible para construir el prototipo.

**Criterios de aceptación:**
- El repositorio contiene una estructura de carpetas acordada para documentación, frontend, backend y base de datos, aunque las capas todavía no implementen lógica funcional.
- Existe un README con descripción del proyecto, alcance académico, tecnologías previstas y forma de colaborar.
- La arquitectura cliente-servidor identifica interfaz web, API REST y persistencia, y describe sus responsabilidades y comunicaciones.
- La estructura y las decisiones iniciales están versionadas en GitHub.

### SAPO-002 — Configurar conexión del backend con PostgreSQL

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como desarrollador, quiero conectar la API Node.js/Express con PostgreSQL, para persistir y consultar de forma fiable los datos del prototipo.

**Criterios de aceptación:**
- El backend establece una conexión con la base de datos PostgreSQL `sapo_db` mediante un cliente o pool configurado.
- Los parámetros de conexión se leen de variables de entorno y existe un ejemplo de configuración sin credenciales reales.
- La aplicación informa de forma controlada cuando la conexión falla y no expone contraseñas ni detalles sensibles.
- Una operación de prueba verifica que el backend puede ejecutar una consulta y cerrar o reutilizar la conexión correctamente.

### SAPO-003 — Definir el esquema de persistencia necesario para personas e incidencias

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como analista/desarrollador, quiero identificar y documentar las entidades y relaciones necesarias para el circuito de personas e incidencias, para asegurar que la base de datos responde al alcance práctico del prototipo.

**Criterios de aceptación:**
- Se identifican las tablas y columnas necesarias para personas, incidencias, usuarios/perfiles y la asociación entre personas e incidencias.
- Se documentan claves primarias, claves foráneas, cardinalidades y restricciones relevantes para el circuito operativo.
- El modelo distingue las entidades imprescindibles del incremento de las tablas destinadas a módulos futuros.
- El esquema documentado es coherente con PostgreSQL y con el SQL ya preparado para `sapo_db`; cualquier ajuste pendiente queda registrado.

### SAPO-004 — Implementar inicio de sesión

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autorizado, quiero iniciar sesión con mis credenciales de prueba, para acceder al prototipo de forma autenticada.

**Criterios de aceptación:**
- Un usuario de prueba válido puede iniciar sesión y obtiene una sesión o mecanismo de autenticación aceptado por la aplicación.
- Las credenciales incorrectas no permiten acceder y muestran un mensaje genérico sin revelar qué dato falló.
- Las contraseñas no se almacenan en texto plano y las credenciales no están codificadas directamente en el repositorio.
- Las rutas protegidas rechazan solicitudes sin autenticación válida.

### SAPO-005 — Aplicar permisos básicos según perfil

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como administrador/usuario de prueba, quiero disponer de permisos según mi perfil, para limitar el acceso a las operaciones autorizadas.

**Criterios de aceptación:**
- Existen al menos dos perfiles de prueba con permisos diferenciados.
- Cada operación protegida comprueba el perfil o permiso requerido en el servidor, no solo en la interfaz.
- Un usuario sin permiso recibe una respuesta de acceso denegado y no modifica datos.
- Los permisos asignados a cada perfil están documentados y se pueden verificar mediante pruebas.

### SAPO-006 — Registrar una persona ficticia

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autenticado autorizado, quiero registrar una persona ficticia, para disponer de sus datos para asociarla al circuito de incidencias.

**Criterios de aceptación:**
- El formulario o endpoint permite registrar una persona con los campos definidos como obligatorios en el modelo.
- Los datos se validan antes de persistir y se rechazan valores obligatorios ausentes o con formato inválido.
- La persona queda almacenada en PostgreSQL y puede recuperarse posteriormente.
- El sistema evita duplicidades en los identificadores únicos y devuelve un resultado comprensible.

### SAPO-007 — Listar, consultar y buscar personas por identificador

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autenticado autorizado, quiero consultar el listado de personas y buscar una por su identificador, para localizar rápidamente un registro ficticio.

**Criterios de aceptación:**
- Se puede obtener un listado de personas registradas, con los campos permitidos para consulta.
- Se puede buscar una persona mediante su identificador único.
- Cuando no existe coincidencia, la aplicación informa de que no se encontró el registro sin producir un error inesperado.
- La consulta no permite acceder a funciones o datos fuera de los permisos del perfil.

### SAPO-008 — Actualizar los datos permitidos de una persona

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autenticado autorizado, quiero modificar los datos editables de una persona ficticia, para mantener la información del registro actualizada.

**Criterios de aceptación:**
- Se puede seleccionar una persona existente y modificar únicamente los campos autorizados.
- Los cambios se validan antes de guardarse y los valores inválidos son rechazados.
- Los cambios persisten en PostgreSQL y se reflejan al volver a consultar la persona.
- El identificador único y los campos no editables no pueden modificarse mediante esta operación.

### SAPO-009 — Archivar una persona

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como usuario con permiso de gestión, quiero archivar una persona que ya no deba aparecer en las consultas ordinarias, para conservar su información sin eliminarla físicamente.

**Criterios de aceptación:**
- La operación de archivo está disponible solo para perfiles autorizados.
- El registro se marca como archivado o inactivo sin borrar físicamente sus datos.
- Las consultas ordinarias distinguen los registros archivados y permiten consultarlos según permisos.
- La acción se valida y no rompe las relaciones existentes con incidencias.

### SAPO-010 — Consultar antecedentes ficticios asociados a una persona, si el flujo lo requiere

**Prioridad:** Media  
**Alcance:** Incremento condicionado

**Historia de usuario:** Como usuario autenticado autorizado, quiero consultar los antecedentes ficticios de una persona cuando sean necesarios para el circuito operativo, para aportar contexto limitado a la consulta de una incidencia.

**Criterios de aceptación:**
- La consulta solo se incorpora si se justifica como necesaria para completar el circuito de incidencias aprobado.
- Los antecedentes mostrados son ficticios y están vinculados de forma inequívoca a la persona seleccionada.
- La consulta es de solo lectura dentro del alcance condicionado; no introduce un módulo CRUD completo.
- Si no existen antecedentes asociados, la aplicación muestra un resultado vacío controlado.

### SAPO-011 — Gestionar antecedentes mediante operaciones completas

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como usuario con permiso de gestión, quiero crear, consultar, modificar y archivar antecedentes ficticios, para gestionar el módulo completo de antecedentes.

**Criterios de aceptación:**
- El módulo permite las operaciones de alta, listado, consulta y modificación definidas para antecedentes.
- Las operaciones validan los datos y mantienen la relación con la persona correspondiente.
- Los permisos de acceso se comprueban en el servidor.
- El módulo se mantiene fuera del incremento práctico comprometido salvo revisión expresa del alcance.

### SAPO-012 — Registrar una incidencia ficticia

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autenticado autorizado, quiero registrar una incidencia ficticia, para iniciar el circuito operativo principal del prototipo.

**Criterios de aceptación:**
- Se puede crear una incidencia con los campos obligatorios definidos en el modelo.
- El sistema valida campos obligatorios, formatos y valores permitidos antes de guardar.
- La incidencia se persiste en PostgreSQL con un identificador único y un estado inicial definido.
- Los errores de validación se comunican sin crear registros incompletos.

### SAPO-013 — Asociar una o varias personas a una incidencia

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autenticado autorizado, quiero asociar una o varias personas ficticias a una incidencia, para reflejar la relación entre las personas y el hecho registrado.

**Criterios de aceptación:**
- Una incidencia puede asociarse a una o varias personas conforme al modelo de datos.
- Solo se pueden asociar personas existentes y no archivadas cuando la regla de negocio así lo exija.
- La relación se persiste y puede recuperarse al consultar la incidencia.
- La aplicación impide relaciones duplicadas y gestiona de forma controlada los intentos no válidos.

### SAPO-014 — Listar y consultar incidencias

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autenticado autorizado, quiero consultar las incidencias registradas y abrir el detalle de una de ellas, para realizar seguimiento del circuito operativo.

**Criterios de aceptación:**
- Se puede obtener un listado de incidencias con los datos resumidos autorizados.
- Se puede consultar el detalle de una incidencia mediante su identificador.
- El detalle incluye su estado y las relaciones con personas cuando estén disponibles.
- Una incidencia inexistente o no accesible produce una respuesta controlada.

### SAPO-015 — Actualizar el estado de una incidencia

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autenticado autorizado, quiero cambiar el estado de una incidencia, para reflejar la evolución del circuito operativo.

**Criterios de aceptación:**
- Los perfiles autorizados pueden cambiar el estado de una incidencia existente.
- Solo se aceptan los estados y transiciones definidos para el prototipo.
- El nuevo estado queda persistido y aparece en las consultas posteriores.
- Las transiciones no permitidas se rechazan sin modificar el estado actual.

### SAPO-016 — Mostrar la ficha integrada de una incidencia y sus personas relacionadas

**Prioridad:** Media  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autenticado autorizado, quiero consultar una ficha que reúna los datos principales de una incidencia y sus personas asociadas, para comprender el registro sin realizar consultas separadas.

**Criterios de aceptación:**
- La ficha reúne los datos principales de la incidencia, su estado y las personas relacionadas.
- La información procede de los registros persistidos y refleja los cambios realizados.
- Solo se muestran campos permitidos para el perfil autenticado.
- La ausencia de personas relacionadas se representa de forma clara y no impide consultar la incidencia.

### SAPO-017 — Gestionar organización y unidades

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como administrador, quiero gestionar los datos de la organización y sus unidades, para representar la estructura organizativa del producto completo.

**Criterios de aceptación:**
- Se pueden registrar y consultar datos generales de una organización y sus unidades.
- Las operaciones de modificación y baja respetan las relaciones entre unidades y registros asociados.
- El acceso está restringido a perfiles administradores.
- Esta funcionalidad queda identificada como visión futura y no se incluye en el incremento práctico actual.

### SAPO-018 — Detectar incidencias pendientes de revisión

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como usuario responsable de seguimiento, quiero identificar incidencias que requieren revisión, para facilitar el seguimiento de registros pendientes.

**Criterios de aceptación:**
- Se define una regla verificable para considerar una incidencia pendiente de revisión.
- La consulta identifica las incidencias que cumplen dicha regla y excluye las demás.
- El resultado puede revisarse sin alterar los datos de la incidencia.
- La funcionalidad queda fuera del incremento actual como evolución futura.

### SAPO-019 — Generar avisos de seguimiento sin duplicados

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como usuario responsable de seguimiento, quiero recibir avisos cuando una incidencia requiera seguimiento, para evitar omisiones y notificaciones repetidas.

**Criterios de aceptación:**
- Se especifican las condiciones que generan un aviso de seguimiento.
- La generación de avisos comprueba si ya existe un aviso equivalente para evitar duplicados.
- Los avisos quedan registrados y asociados a la incidencia correspondiente.
- La automatización y sus reglas se planifican como funcionalidad futura, no como parte del Sprint 1.

### SAPO-020 — Generar informes de incidencias por periodo y estado

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como responsable del sistema, quiero obtener informes de incidencias filtrados por periodo y estado, para analizar la actividad registrada.

**Criterios de aceptación:**
- El informe permite seleccionar un periodo y uno o varios estados.
- Los resultados se corresponden con los datos almacenados y los filtros seleccionados.
- Se muestran totales y detalle de forma legible, con el periodo consultado.
- El informe se identifica como módulo futuro de la visión del producto.

### SAPO-021 — Generar informes de actividad por tipo

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como responsable del sistema, quiero obtener informes agrupados por tipo de actividad, para conocer la distribución de la actividad registrada.

**Criterios de aceptación:**
- Se define un catálogo de tipos de actividad usado para agrupar los registros.
- El informe presenta cantidades por tipo para el periodo seleccionado, cuando proceda.
- Los totales se pueden contrastar con los registros de origen.
- La funcionalidad permanece fuera del alcance de implementación actual.

### SAPO-022 — Consultar estadísticas agregadas

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como responsable del sistema, quiero consultar indicadores agregados del circuito operativo, para obtener una visión resumida de la actividad.

**Criterios de aceptación:**
- Se documentan los indicadores, las fórmulas de cálculo y el origen de sus datos.
- Los resultados se calculan a partir de datos persistidos y respetan los filtros aplicados.
- Los indicadores se muestran sin exponer datos personales ficticios innecesarios.
- La consulta estadística se mantiene como evolución futura.

### SAPO-023 — Registrar eventos de auditoría

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como administrador/responsable de seguridad, quiero registrar eventos relevantes de uso y modificación, para disponer de trazabilidad de las operaciones.

**Criterios de aceptación:**
- Se identifican los tipos de evento que deben registrarse y los datos mínimos de cada evento.
- Los eventos se almacenan de forma estructurada y vinculada al usuario y momento, cuando estén disponibles.
- El registro no almacena contraseñas ni secretos.
- La auditoría avanzada se documenta como funcionalidad futura; los controles básicos de seguridad sí se consideran en el incremento.

### SAPO-024 — Consultar el histórico de auditoría

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como administrador autorizado, quiero consultar el histórico de eventos de auditoría, para revisar las operaciones registradas.

**Criterios de aceptación:**
- El histórico permite consultar eventos por criterios básicos, como periodo, usuario o tipo.
- Los resultados muestran fecha, tipo de evento y referencia al elemento afectado, según permisos.
- Los usuarios sin permiso de auditoría no pueden consultar el histórico.
- La funcionalidad queda fuera del incremento práctico actual.

### SAPO-025 — Administrar usuarios y perfiles

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como administrador, quiero crear, consultar, modificar y desactivar usuarios y perfiles, para administrar las cuentas del producto completo.

**Criterios de aceptación:**
- El módulo permite gestionar cuentas y perfiles mediante operaciones controladas.
- Las reglas impiden dejar el sistema sin un administrador activo y evitan asignaciones inválidas.
- Las contraseñas se protegen y las operaciones requieren permisos administrativos.
- La administración completa queda como producto futuro; el incremento actual solo requiere perfiles de prueba y permisos básicos.

### SAPO-026 — Incorporar filtros avanzados de búsqueda

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como usuario autenticado autorizado, quiero combinar varios criterios de búsqueda, para localizar registros de manera más precisa.

**Criterios de aceptación:**
- Se definen criterios combinables y su comportamiento cuando se usan juntos.
- Los filtros se aplican en el servidor y devuelven resultados coherentes con los criterios seleccionados.
- La búsqueda respeta permisos y valida los valores recibidos.
- Los filtros avanzados quedan fuera del incremento actual; se mantienen únicamente las consultas básicas necesarias.

### SAPO-027 — Verificar el flujo mediante pruebas funcionales y de integración

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como responsable de calidad/desarrollador, quiero verificar el circuito de personas e incidencias con pruebas reproducibles, para detectar errores y demostrar que el incremento cumple sus requisitos.

**Criterios de aceptación:**
- Existen pruebas para los flujos principales de alta y consulta de personas e incidencias, asociación y actualización de estado.
- Se prueban también escenarios de error relevantes, como datos inválidos, identificadores inexistentes y permisos insuficientes.
- Las pruebas pueden ejecutarse de forma repetible y sus resultados quedan documentados.
- Las pruebas de integración verifican la interacción con PostgreSQL y no dependen de sistemas reales externos.

### SAPO-028 — Documentar instalación, configuración y uso del prototipo

**Prioridad:** Media  
**Alcance:** Incremento

**Historia de usuario:** Como desarrollador/usuario evaluador, quiero disponer de instrucciones para preparar y ejecutar el prototipo, para facilitar su revisión y demostración académica.

**Criterios de aceptación:**
- La documentación enumera los requisitos previos y las versiones tecnológicas necesarias.
- Se describen los pasos de configuración de base de datos, variables de entorno, instalación de dependencias y arranque, a medida que estén implementados.
- Se proporciona un ejemplo de variables de entorno sin credenciales reales.
- Las instrucciones permiten a otra persona reproducir el entorno siguiendo los pasos documentados, cuando el prototipo esté implementado.

### SAPO-029 — Definir procedimientos completos de copia y recuperación

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como administrador, quiero disponer de procedimientos de copia de seguridad y recuperación, para preservar la información ante fallos.

**Criterios de aceptación:**
- Se documentan la frecuencia, el alcance y la ubicación prevista de las copias.
- Se describen los pasos de recuperación y las comprobaciones posteriores.
- Se identifican responsabilidades y riesgos del procedimiento.
- La automatización y operación completa de copias y recuperación quedan como alcance futuro.

### SAPO-030 — Revisar seguridad, privacidad y tratamiento de datos ficticios

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como responsable del proyecto, quiero aplicar criterios básicos de seguridad y privacidad al prototipo, para evitar exposición de secretos y asegurar el carácter académico de los datos.

**Criterios de aceptación:**
- Se establece que todos los datos utilizados son ficticios y que no se incorporan datos personales reales ni conexiones a sistemas policiales, judiciales o administrativos.
- Las credenciales y secretos se excluyen del código y del control de versiones.
- Se definen controles básicos de autenticación, autorización, validación de entradas y gestión de errores.
- Se documentan las limitaciones del prototipo y la ausencia de despliegue en producción.

## 6. Desglose técnico orientativo

Las historias pueden descomponerse en tareas técnicas al planificar cada iteración. Como mínimo, el trabajo del incremento práctico deberá cubrir:

1. Estructura del repositorio, arquitectura y documentación inicial.
2. Revisión del modelo de datos y preparación de PostgreSQL ya disponible.
3. Configuración de variables de entorno y conexión de Node.js/Express con PostgreSQL.
4. Implementación de autenticación y permisos básicos.
5. Operaciones de registro y consulta de personas ficticias.
6. Operaciones de registro y consulta de incidencias ficticias.
7. Asociación de personas con incidencias y actualización de estado.
8. Validaciones de entrada y reglas de negocio.
9. Pruebas funcionales y de integración con PostgreSQL.
10. Documentación de instalación, configuración y ejecución.
11. Revisión de seguridad básica, tratamiento de datos ficticios y limitaciones.

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
- Las operaciones sobre personas incluidas en el alcance permiten registrar, listar, consultar y modificar los datos autorizados.
- El sistema dispone de inicio de sesión y al menos dos perfiles de prueba con permisos diferenciados.
- Las entradas se validan y los errores se gestionan sin dejar datos inconsistentes.
- Las pruebas verifican los flujos principales y casos de error.
- La documentación permite configurar y ejecutar el prototipo en un entorno de desarrollo.

## 9. Gestión y trazabilidad

El repositorio contiene el código y la documentación versionada. GitHub Issues representa cada elemento del backlog mediante su identificador SAPO; GitHub Projects permite priorizar, clasificar por alcance, reflejar el estado y asignar iteraciones. La planificación de cada sprint concretará las tareas, responsables, criterios de aceptación aplicables y resultados esperados.

- [Repositorio](https://github.com/Zanguango/SAPO)
- [Documento del Product Backlog](https://github.com/Zanguango/SAPO/blob/main/docs/PRODUCT_BACKLOG.md)
- [Tablero de gestión](https://github.com/users/Zanguango/projects/1)

La selección de historias y el orden de ejecución podrán revisarse durante la planificación, manteniendo como prioridad el circuito operativo principal y evitando ampliar el alcance sin justificación.
