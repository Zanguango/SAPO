# S.A.P.O. — Product Backlog

**Proyecto:** Sistema Avanzado Policial Operativo  
**Asignatura:** Proyecto de Ingeniería de Software (47GIIN) — VIU  
**Autor:** Ignacio Teruel Cuartero  
**Repositorio:** [Zanguango/SAPO](https://github.com/Zanguango/SAPO)  
**Tablero:** [SAPO – Gestión del proyecto](https://github.com/users/Zanguango/projects/1)  
**Versión:** 1.3 — 26 de noviembre de 2026

> **Naturaleza del proyecto.** S.A.P.O. es un prototipo académico de un escenario simulado y utiliza exclusivamente datos ficticios. No se conecta con sistemas policiales, judiciales ni administrativos reales. «Avanzado» alude a la integración funcional, no a inteligencia artificial ni a capacidades predictivas. El resultado es un prototipo en entorno de desarrollo o demostración, no un sistema de producción.

## 1. Visión del producto

Integrar información ficticia de personas e incidencias para facilitar el registro y consulta de actuaciones en un entorno académico controlado, con persistencia relacional, validaciones y autenticación con permisos básicos.

## 2. Alcance comprometido para la asignatura

La implementación práctica se concentra en aproximadamente el 20 % del producto. No se limita al circuito personas–incidentes: también incluye las versiones mínimas expresamente seleccionadas en la propuesta aprobada, aunque se desarrollen en sprints posteriores. **Un elemento de alcance Incremento sigue comprometido para la entrega de 47GIIN aunque todavía no se haya planificado en el sprint actual.**

**Dentro del incremento:** estructura y arquitectura; conexión de la API con PostgreSQL; operaciones de alta/listado/consulta/modificación de personas; circuito de incidencias asociadas a personas y actualización de estado; autenticación y permisos básicos con al menos dos perfiles de prueba; CRUD mínimo de datos generales de la organización; tarea programada de seguimiento sin duplicados; dos reportes; una estadística; auditoría mínima de acciones relevantes y consulta restringida; pruebas; documentación y verificación básica de backup/restauración.

**Visión futura (fuera del incremento de esta asignatura):** archivo de personas; gestión completa de antecedentes; administración completa de usuarios y perfiles; gestión CRUD de unidades organizativas, catálogos y ubicaciones; gestión completa de documentos, asignaciones y módulos auxiliares; filtros avanzados; automatización empresarial y administración avanzada de auditoría; y políticas empresariales de backup/recuperación. La persistencia, catálogos de soporte y registros mínimos necesarios para las funcionalidades comprometidas sí forman parte del prototipo.

**Interpretación de alcance:** `Incremento` significa que se construirá durante el proyecto 47GIIN, no necesariamente en el Sprint 1. `Futuro` significa fuera del incremento comprometido para la asignatura. Consulta [docs/PROJECT_BASELINE.md](PROJECT_BASELINE.md) para la matriz de alcance y los criterios rectores.

**Referencia única del modelo de datos:** el diseño existente se documenta en [docs/DATABASE_DESIGN.md](DATABASE_DESIGN.md). La preparación y primera ejecución del esquema SQL son trabajo previo al Sprint 1; las historias que reutilicen esa estructura deben enlazar esta evidencia, sin volver a atribuirse la creación del modelo. Cualquier modificación futura del modelo deberá vincularse a un requisito/historia y registrarse mediante el procedimiento de control de cambios.

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
| SAPO-017 | Gestionar datos generales de la organización (CRUD mínimo) | Alta | Incremento |
| SAPO-018 | Detectar incidencias pendientes de revisión para el proceso automático | Alta | Incremento |
| SAPO-019 | Generar avisos de seguimiento sin duplicados mediante una tarea programada | Alta | Incremento |
| SAPO-020 | Generar el reporte de incidencias por periodo y estado | Alta | Incremento |
| SAPO-021 | Generar el segundo reporte: actividad por tipo y detalle de incidencias | Alta | Incremento |
| SAPO-022 | Consultar la estadística agregada del circuito | Alta | Incremento |
| SAPO-023 | Registrar eventos mínimos de auditoría de las operaciones comprometidas | Media | Incremento |
| SAPO-024 | Consultar el histórico mínimo de auditoría con acceso restringido | Media | Incremento |
| SAPO-025 | Administrar usuarios y perfiles | Baja | Futuro |
| SAPO-026 | Incorporar filtros avanzados de búsqueda | Baja | Futuro |
| SAPO-027 | Verificar el flujo mediante pruebas funcionales y de integración | Alta | Incremento |
| SAPO-028 | Documentar instalación, configuración y uso del prototipo | Media | Incremento |
| SAPO-029 | Verificar copia y restauración básica de PostgreSQL en entorno de prueba | Media | Incremento |
| SAPO-030 | Revisar seguridad, privacidad y tratamiento de datos ficticios | Alta | Incremento |
| SAPO-031 | Justificar la normalización del modelo completo en 1FN, 2FN y 3FN | Alta | Incremento |
| SAPO-032 | Modelar las interfaces del 50 % del producto y las salidas | Alta | Incremento |

**Total: 32 elementos** tras incorporar los dos entregables de diseño exigidos por la asignatura. La asignación a una iteración se gestiona en GitHub Projects y no cambia la pertenencia de un elemento al Product Backlog.

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
- Se identifican las entidades vinculadas cuyos registros deben existir previamente para poder utilizar las operaciones y se define un mecanismo de provisión de datos ficticios iniciales (por ejemplo, scripts SQL de carga o fixtures), documentando dependencias y orden de carga.

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

### SAPO-010 — Consultar antecedentes ficticios asociados a una persona

**Prioridad:** Baja  
**Alcance:** Futuro

**Historia de usuario:** Como usuario autorizado, quiero consultar antecedentes ficticios de una persona, para disponer de contexto en el producto completo.

**Criterios de aceptación:**
- La consulta se realiza exclusivamente sobre datos ficticios y vinculados a la persona seleccionada.
- La consulta es de solo lectura y gestiona correctamente la ausencia de resultados.
- El módulo de antecedentes queda fuera del incremento práctico mínimo aprobado, salvo cambio de alcance autorizado.

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

### SAPO-017 — Gestionar datos generales de la organización (CRUD mínimo)

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como usuario autorizado de administración, quiero crear, consultar, modificar y archivar los datos generales ficticios de la organización, para utilizarlos en las cabeceras y los informes del prototipo.

**Criterios de aceptación:**
- Se pueden crear y consultar/listar los datos generales de la organización ficticia.
- Se pueden modificar los campos permitidos y archivar o desactivar lógicamente un dato obsoleto, respetando las referencias existentes.
- Los datos se persisten en PostgreSQL y se validan en servidor.
- Este alcance no incluye el CRUD completo de unidades organizativas, que se mantiene como evolución futura.

### SAPO-018 — Detectar incidencias pendientes de revisión para el proceso automático

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como responsable del sistema, quiero que una tarea programada identifique incidencias que lleven en estado pendiente más de un umbral configurable, para activar su seguimiento sin intervención manual.

**Criterios de aceptación:**
- El proceso identifica solo incidencias activas que permanecen en el estado de revisión definido durante el umbral configurado.
- El tiempo se calcula desde el último cambio efectivo al estado pendiente, no desde una modificación genérica de otros campos.
- La regla y el umbral quedan documentados y son verificables con fechas controladas.
- La detección por sí sola no altera el estado de la incidencia.

### SAPO-019 — Generar avisos de seguimiento sin duplicados mediante una tarea programada

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como responsable de seguimiento, quiero que el proceso automático cree un registro de aviso vinculado a la incidencia que supera el umbral, para dejar constancia y evitar duplicidades.

**Criterios de aceptación:**
- Cuando una incidencia cumple la condición de SAPO-018, el proceso crea un aviso ficticio vinculado a ella y registra la ejecución.
- Antes de insertarlo, comprueba si ya existe un aviso equivalente; ejecutar dos veces el proceso no duplica el aviso.
- El aviso queda persistido y puede consultarse desde la ficha o el reporte correspondiente.
- El proceso se ejecuta sin intervención manual una vez configurado y no envía mensajes ni comunicaciones externas.

### SAPO-020 — Generar el reporte de incidencias por periodo y estado

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como responsable del sistema, quiero obtener un listado de incidencias por periodo y estado, para analizar la actividad del circuito implementado.

**Criterios de aceptación:**
- El reporte permite seleccionar un periodo y uno o varios estados dentro de los filtros básicos definidos.
- Los resultados y totales corresponden con las incidencias persistidas y los filtros seleccionados.
- Se controla el caso sin resultados y se respetan los permisos de acceso.
- Los datos del reporte se verifican con un conjunto de prueba conocido.

### SAPO-021 — Generar el segundo reporte: actividad por tipo y detalle de incidencias

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como responsable del sistema, quiero consultar la actividad agrupada por tipo de incidente y acceder al detalle de un incidente, para conocer su contexto operativo y las personas relacionadas.

**Criterios de aceptación:**
- El reporte agrupa la actividad por tipo de incidente y presenta totales verificables.
- Desde el resultado se puede consultar el detalle de la incidencia seleccionada, incluyendo sus personas vinculadas y los datos de seguimiento permitidos.
- No se muestran campos no autorizados ni datos sensibles innecesarios.
- El resultado se contrasta con datos de prueba conocidos.

### SAPO-022 — Consultar la estadística agregada del circuito

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como responsable del sistema, quiero consultar un indicador estadístico agregado de las incidencias, para obtener una visión resumida del circuito.

**Criterios de aceptación:**
- Se implementa al menos un conteo de incidencias por tipo o estado en un periodo seleccionado.
- La fórmula, origen de datos y filtros quedan documentados.
- Los valores se contrastan con un conjunto de prueba conocido.
- Se presentan datos agregados y no se exponen datos personales innecesarios.

### SAPO-023 — Registrar eventos mínimos de auditoría de las operaciones comprometidas

**Prioridad:** Media  
**Alcance:** Incremento

**Historia de usuario:** Como responsable del proyecto, quiero registrar las acciones relevantes sobre personas, incidencias, organización y seguimiento, para mantener la trazabilidad del prototipo.

**Criterios de aceptación:**
- Se registran, como mínimo, usuario u origen, fecha/hora, acción, entidad afectada e identificador del registro cuando proceda.
- Para modificaciones relevantes se conservan valores anteriores y posteriores de los campos permitidos, excluyendo contraseñas, tokens, secretos y datos sensibles innecesarios.
- Los eventos se almacenan de forma append-only y no se modifican ni eliminan desde las operaciones ordinarias.
- La auditoría avanzada de todo el producto queda fuera del incremento.

### SAPO-024 — Consultar el histórico mínimo de auditoría con acceso restringido

**Prioridad:** Media  
**Alcance:** Incremento

**Historia de usuario:** Como usuario con permisos de supervisión/administración, quiero consultar los eventos de auditoría del circuito implementado, para revisar las acciones relevantes.

**Criterios de aceptación:**
- Se puede consultar un listado acotado de eventos con filtros básicos por periodo, usuario o tipo de acción.
- Solo los perfiles autorizados pueden consultar el histórico; la autorización se comprueba en el backend.
- La consulta devuelve únicamente los datos necesarios y nunca expone contraseñas, tokens o secretos.

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

### SAPO-029 — Verificar copia y restauración básica de PostgreSQL en entorno de prueba

**Prioridad:** Media  
**Alcance:** Incremento

**Historia de usuario:** Como responsable del prototipo, quiero disponer de un procedimiento básico de copia y restauración y verificarlo en una base aislada, para demostrar la recuperación de la persistencia.

**Criterios de aceptación:**
- Se documentan los comandos/procedimiento de copia y restauración adecuados al entorno académico.
- Se realiza una copia de una base de prueba y se restaura en una instancia limpia o aislada.
- Tras restaurar, se verifican recuentos y relaciones relevantes.
- La prueba nunca se realiza sobre datos reales ni sobrescribe la base local de trabajo.
- La automatización empresarial y las políticas avanzadas de backup quedan fuera del incremento.

### SAPO-030 — Revisar seguridad, privacidad y tratamiento de datos ficticios

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como responsable del proyecto, quiero aplicar criterios básicos de seguridad y privacidad, para evitar exposición de secretos y preservar el carácter académico.

**Criterios de aceptación:**
- Se utilizan exclusivamente datos ficticios; no hay conexiones a sistemas institucionales reales.
- Las credenciales y secretos se excluyen del código y del control de versiones.
- Se documentan autenticación, permisos, validación de entradas, errores y limitación de uso fuera de producción.

### SAPO-031 — Justificar la normalización del modelo completo en 1FN, 2FN y 3FN

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como analista/desarrollador, quiero justificar formalmente las tres primeras formas normales del modelo de datos completo, para acreditar el requisito de diseño de la asignatura.

**Criterios de aceptación:**
- Se documentan las 24 relaciones del modelo, sus atributos, claves primarias/candidatas y dependencias funcionales relevantes.
- Se justifica, relación por relación, el cumplimiento de 1FN, 2FN y 3FN o se identifican y corrigen las excepciones.
- Se explica el tratamiento de los campos JSONB de AUDITORIA y EJECUCION_PROCESO respecto a atomicidad/1FN, sin dar por válida la normalización únicamente por usar PostgreSQL.
- El análisis se contrasta con el SQL de referencia y queda enlazado desde DATABASE_DESIGN.md.

### SAPO-032 — Modelar las interfaces del 50 % del producto y las salidas

**Prioridad:** Alta  
**Alcance:** Incremento

**Historia de usuario:** Como responsable del diseño, quiero modelar las interfaces de usuario de al menos el 50 % del producto y sus salidas principales, para cumplir los requisitos de diseño y facilitar la implementación.

**Criterios de aceptación:**
- Existe un inventario de pantallas previstas para el producto completo y se identifica de forma explícita cuáles forman el 50 % modelado.
- Se modelan los flujos principales de personas, incidencias, autenticación/permisos, organización, seguimiento e informes/estadística que correspondan al alcance.
- Se representan estados, campos, acciones, validaciones, navegación y restricciones de visibilidad por perfil.
- Se modelan las salidas de los dos reportes y de la estadística, con campos y filtros.
- Los prototipos/diseños se enlazan desde la documentación y se mantienen coherentes con el Product Backlog y el modelo de datos.

## 6. Desglose técnico orientativo

1. Preparación del entorno y de la conexión Node.js/Express–PostgreSQL.
2. Preparación reproducible de datos ficticios y catálogos necesarios.
3. Implementación de autenticación y permisos básicos con perfiles de prueba.
4. CRUD mínimo de personas e implementación del circuito de incidencias asociadas.
5. CRUD mínimo de datos generales de la organización.
6. Proceso programado de detección de pendientes y creación idempotente de avisos.
7. Reporte por periodo/estado, segundo reporte por tipo con detalle y estadística agregada.
8. Registro y consulta restringida de auditoría mínima.
9. Pruebas unitarias, de integración y funcionales; copia/restauración de PostgreSQL en entorno aislado.
10. Modelado de interfaces del 50 % de las pantallas y de las salidas de reporte.
11. Justificación formal de 1FN, 2FN y 3FN del modelo global.
12. Documentación, seguridad y demostración académica.

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
- Se completa el circuito de alta, listado, consulta y modificación de personas y el circuito de registro/consulta/actualización de estado de incidencias relacionadas.
- Se implementa el CRUD mínimo de datos generales de la organización.
- Existe inicio de sesión y al menos dos perfiles de prueba con permisos diferenciados, comprobados en backend.
- El proceso programado detecta incidencias pendientes tras un umbral y crea avisos de seguimiento sin duplicados ni comunicaciones externas.
- Se generan dos reportes (periodo/estado y actividad por tipo con detalle) y al menos una estadística agregada del circuito.
- Se registra auditoría mínima de las operaciones relevantes y su consulta está restringida.
- Las entradas se validan y los errores se gestionan sin dejar datos inconsistentes.
- Las pruebas verifican los flujos principales, errores y restauración de una copia en entorno aislado.
- La documentación permite preparar, configurar y ejecutar el prototipo.

## 9. Gestión y trazabilidad

El repositorio contiene el código y la documentación versionada. GitHub Issues representa cada elemento mediante su identificador SAPO; GitHub Projects permite priorizar, clasificar por alcance, reflejar el estado y asignar iteraciones. La planificación de cada sprint concretará tareas, responsable, criterios aplicables y resultados esperados.

- [Repositorio](https://github.com/Zanguango/SAPO)
- [Documento del Product Backlog](https://github.com/Zanguango/SAPO/blob/main/docs/PRODUCT_BACKLOG.md)
- [Tablero de gestión](https://github.com/users/Zanguango/projects/1)

La selección de historias podrá revisarse en la planificación, manteniendo como prioridad el circuito principal y evitando ampliar el alcance sin justificación.
