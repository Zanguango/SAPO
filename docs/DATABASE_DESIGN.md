# Diseño de la base de datos de S.A.P.O.

**Proyecto:** Sistema Avanzado Policial Operativo  
**Asignatura:** Proyecto de Ingeniería de Software (47GIIN)  
**Autor:** Ignacio Teruel Cuartero  
**Base de datos:** PostgreSQL 18.7  
**Base local:** `sapo_db` · esquema `public`

## 1. Finalidad del modelo

Este documento es la referencia documental única del diseño de la base de datos de S.A.P.O. El modelo relacional fue preparado antes del Sprint 1 para dar soporte al producto completo y relacionar personas, antecedentes, incidencias, usuarios, perfiles, organización, auditoría y procesos de seguimiento.

Durante el Sprint 1 no se creó ni se volvió a ejecutar el esquema: se revisó el modelo existente, se delimitó su aplicación al circuito práctico y se documentaron sus relaciones y dependencias. Para la implementación práctica, el circuito prioritario se centra en registrar y consultar incidencias ficticias asociadas a personas. El resto de entidades forman parte del modelo global y se incorporarán funcionalmente solo cuando correspondan al alcance aprobado.

La base utiliza claves primarias, claves foráneas, restricciones, índices y mecanismos de integridad para mantener la coherencia entre los registros. La versión SQL de referencia se conserva como [candidato versionado](../database/schema/SAPO_CORREGIDO_REVISION_ESTATICA_CANDIDATO.sql). El contraste con `sapo_db` permitió identificar reglas adicionales de integridad que se han aceptado para el modelo global e incorporado al SQL versionado. El script sigue pendiente de validación integral en una base aislada; no debe utilizarse para recrear ni modificar la instancia local.

## 2. Estructura general

La estructura implementada en el script de referencia contiene:

| Elemento | Cantidad |
|---|---:|
| Tablas | 24 |
| Claves foráneas | 31 |
| Índices | 38 |
| Triggers | 48 |
| Sentencias `CREATE OR REPLACE FUNCTION` | 41 |
| Nombres de función distintos en el script | 37 |

La base separa los datos principales, los catálogos, las relaciones entre entidades y los elementos de trazabilidad. Los identificadores se generan en la base de datos mediante `GENERATED ALWAYS AS IDENTITY` y las relaciones se protegen mediante claves y restricciones.

### Inventario de las 24 tablas

| Área | Tablas |
|---|---|
| Organización, unidades y acceso | `ORGANIZACION`, `UNIDAD_ORGANIZATIVA`, `PERFIL`, `USUARIO`, `HISTORIAL_PERTENENCIA_ORGANIZATIVA`, `HISTORIAL_UNIDAD_USUARIO`, `HISTORIAL_PERFIL_USUARIO` |
| Personas y antecedentes | `PERSONA`, `TIPO_ANTECEDENTE`, `ANTECEDENTE` |
| Incidentes y catálogos | `TIPO_INCIDENTE`, `ESTADO_INCIDENTE`, `TRANSICION_ESTADO_INCIDENTE`, `UBICACION`, `INCIDENTE`, `VINCULACION_PERSONA_INCIDENTE` |
| Operación y trazabilidad | `ASIGNACION_INCIDENTE`, `DOCUMENTO_ASOCIADO`, `AVISO_SEGUIMIENTO`, `AUDITORIA` |
| Procesos y alertas técnicas | `EJECUCION_PROCESO`, `ALERTA_TECNICA`, `ACTUACION_ALERTA`, `CONFIGURACION_UMBRAL` |

## 3. Entidades principales del circuito

| Entidad | Responsabilidad |
|---|---|
| `PERSONA` | Almacenar los datos de personas ficticias. |
| `INCIDENTE` | Registrar cada incidente ficticio, su tipo, estado, organización y ubicación opcional. |
| `VINCULACION_PERSONA_INCIDENTE` | Relacionar personas e incidentes e indicar el tipo de vinculación. |
| `ORGANIZACION` | Mantener los datos generales de la organización ficticia. |
| `TIPO_INCIDENTE` | Mantener los tipos o categorías de incidente. |
| `ESTADO_INCIDENTE` | Definir los estados válidos de los incidentes. |
| `TRANSICION_ESTADO_INCIDENTE` | Controlar las transiciones permitidas entre estados. |
| `UBICACION` | Mantener ubicaciones ficticias que pueden asociarse a incidentes. |

La relación entre personas e incidentes es de muchos a muchos y se resuelve mediante `VINCULACION_PERSONA_INCIDENTE`. Así puedo asociar varias personas a un incidente y una persona a distintos incidentes, conservando el tipo de vinculación correspondiente. El esquema limita `tipo_vinculacion` a los códigos `VICTIMA`, `AFECTADO`, `PERJUDICADO`, `DENUNCIANTE`, `TESTIGO`, `INVESTIGADO`, `DETENIDO`, `PRESUNTO_AUTOR`, `REPRESENTANTE`, `SOLICITANTE`, `AGENTE_ACTUANTE` y `OTRO`.

## 4. Entidades de soporte y trazabilidad

El modelo completo incorpora también entidades para usuarios y perfiles, historial de asignación de perfiles, historial de pertenencia organizativa, antecedentes y sus tipos, documentos asociados, asignaciones, auditoría, ejecución de procesos, alertas y configuración de umbrales. El esquema incluye tres perfiles base protegidos: `ADMINISTRADOR`, `SUPERVISOR` y `AGENTE`. Esto no obliga a implementar la administración completa de perfiles en el incremento práctico.

Estas entidades amplían el producto global. Su presencia en el modelo de datos no significa que todas sus operaciones vayan a implementarse en el incremento práctico.

## 5. Relaciones y dependencias

Para registrar un incidente deben existir previamente:
- una organización;
- un tipo de incidente;
- un estado válido.

La ubicación es opcional. Para asociar una persona a un incidente deben existir ambos registros. Si se activa la consulta de antecedentes, el antecedente necesita una persona y un tipo de antecedente existentes.

Los tipos de vinculación de persona-incidente se validan mediante las restricciones definidas en el esquema. Las transiciones entre estados también se limitan mediante el catálogo de transiciones y las reglas asociadas.

Estas dependencias determinan el orden de preparación de los datos iniciales de prueba.

## 6. Integridad y reglas de negocio

En el diseño se utilizan:
- claves primarias para identificar cada registro;
- claves foráneas para mantener relaciones válidas;
- restricciones `NOT NULL`, `UNIQUE` y `CHECK` para limitar valores;
- índices para apoyar búsquedas y garantizar unicidad cuando corresponde;
- funciones y triggers PL/pgSQL para validar operaciones, proteger registros y controlar reglas de negocio;
- estados y transiciones para restringir la evolución de los incidentes.

Las operaciones de la futura API deberán respetar estas reglas y no sustituirlas por validaciones únicamente en la interfaz.

## 7. Relación con los requisitos de la asignatura

| Requisito | Cómo lo aborda el diseño |
|---|---|
| Persistencia SQL | El modelo se implementa en PostgreSQL. |
| Circuito operativo personas-incidentes | Las tablas principales y la tabla de vinculación permiten registrar y relacionar ambos tipos de registro. |
| Datos generales de organización | Existe la entidad `ORGANIZACION`, utilizada además como referencia obligatoria del incidente. |
| Usuarios y perfiles | El modelo contiene usuarios, perfiles e historial de asignación. |
| Auditoría y trazabilidad | Se contemplan entidades y reglas para registrar operaciones y procesos. |
| Integridad de datos | Se definen PK, FK, restricciones, índices, funciones y triggers. |
| Normalización | El modelo se estructura en entidades y catálogos separados. La justificación formal tabla por tabla de 1FN, 2FN y 3FN debe quedar documentada en la revisión de normalización del modelo completo. |

El SQL contiene cuatro redefiniciones de función mediante `CREATE OR REPLACE`: `fn_proteger_historial_organizativo`, `fn_validar_aviso_seguimiento`, `fn_validar_alerta_tecnica` y `fn_proteger_version_umbral`. Tras incorporar la función común de bloqueo del borrado físico, el candidato contiene 41 sentencias de definición y 37 nombres de función distintos.

El requisito de normalización no se da por acreditado solo por contar tablas y relaciones. Sigue pendiente una justificación formal de 1FN, 2FN y 3FN para las 24 tablas, revisando atributos, claves candidatas y dependencias funcionales. En particular, las columnas `JSONB` de `AUDITORIA` y `EJECUCION_PROCESO` requieren explicar expresamente cómo se tratan respecto a la atomicidad exigida por 1FN; no debe afirmarse la normalización completa hasta resolverlo. La tarea está registrada como [SAPO-031](https://github.com/Zanguango/SAPO/issues/52).

El modelo de datos no implica que la API, la interfaz, los CRUD, los informes, las estadísticas o el proceso automatizado estén ya implementados. La propuesta aprobada compromete un incremento mínimo que incluye el circuito personas–incidentes, autenticación/permisos, CRUD básico de datos generales de organización, automatización de seguimiento, dos reportes y una estadística. Su desarrollo se distribuye entre sprints posteriores al Sprint 1. El detalle del alcance está en [docs/PROJECT_BASELINE.md](PROJECT_BASELINE.md) y en el [Product Backlog](PRODUCT_BACKLOG.md).

## 8. Estado de la base local

Antes del inicio del Sprint 1 ya había creado la base local `sapo_db` y ejecutado el esquema. Ese trabajo constituye la situación de partida del proyecto y no lo contabilizo como trabajo realizado dentro del sprint.

El 26/11/2026 he verificado en pgAdmin 4 que mi instancia utiliza PostgreSQL 18.7, esquema `public`, y contiene:

| Indicador | Resultado |
|---|---:|
| Tablas | 24 |
| Claves foráneas | 31 |
| Organizaciones | 1 |
| Tipos de incidente | 7 |
| Estados | 4 |
| Transiciones | 5 |
| Personas | 0 |
| Incidentes | 0 |

La captura de pgAdmin confirma los recuentos locales de tablas y claves foráneas. Esta comprobación no equivale a una auditoría individual de cada columna, índice, restricción, función y trigger de la instancia. Para completar esa comparación sin modificar datos ni objetos se ha preparado [el diagnóstico SQL de solo lectura](../database/diagnostics/AUDITAR_ESQUEMA_LOCAL_SOLO_LECTURA.sql), asociado a la [tarea técnica #54](https://github.com/Zanguango/SAPO/issues/54).

Los siete tipos de incidente aparecen con fecha de creación 17/11/2026 a las 18:48:43 aproximadamente, anterior al inicio del Sprint 1. La consulta de recuento confirma que existe una organización, pero todavía debo recuperar el origen de su alta y de los tipos de incidente para poder reproducirlos desde una base vacía.

## 9. Datos iniciales y reproducibilidad

He separado el diseño del esquema de los datos de demostración. El candidato SQL revisado incluye los tres perfiles base, los cuatro estados de incidente y las cinco transiciones de estado. No incorpora registros iniciales de ORGANIZACION ni TIPO_INCIDENTE. La organización y los siete tipos de incidente ya existen en mi instancia local, pero debo identificar el mecanismo que los creó mediante la [tarea técnica #51](https://github.com/Zanguango/SAPO/issues/51). No afirmaré que el SQL candidato es idéntico al estado local sin una comparación técnica completa.

No volveré a insertar esos registros ni a recrear la base hasta localizar su origen o preparar una carga equivalente que:
- use datos exclusivamente ficticios;
- respete claves y restricciones;
- no escriba manualmente identificadores de identidad;
- pueda repetirse sin duplicar registros;
- se pruebe primero en una base aislada.

La estrategia y la tarea pendiente están en [database/seeds/README.md](../database/seeds/README.md) y en la [tarea técnica #51](https://github.com/Zanguango/SAPO/issues/51). Las decisiones de alcance y continuidad se consolidan en [docs/PROJECT_BASELINE.md](PROJECT_BASELINE.md).

## 10. Revisión del diseño y contraste con la instancia local

El modelo relacional evolucionó desde una definición anterior hacia una revisión que incorporó cuatro ajustes de consistencia:

- Retirada de una cláusula `FOR UPDATE` situada dentro de un `EXISTS` de validación de transiciones, donde no era válida.
- Separación de las validaciones de alta y reactivación de las vinculaciones persona–incidente, comprobando que la persona y el incidente estén activos y que el incidente no se encuentre en un estado terminal.
- Protección de los documentos archivados frente a modificaciones.
- Ampliación de la validación de las ejecuciones de proceso para que también se compruebe su alta (`INSERT`).

La versión SQL revisada se conserva como [candidato versionado](../database/schema/SAPO_CORREGIDO_REVISION_ESTATICA_CANDIDATO.sql). Su inventario estático actual contiene 24 tablas, 31 claves foráneas, 38 índices declarados mediante `CREATE INDEX`, 48 triggers y 41 sentencias `CREATE OR REPLACE FUNCTION`, que corresponden a 37 nombres de función distintos porque cuatro se redefinen.

### Resultado del primer contraste con `sapo_db` (26/11/2026)

Se ejecutó el diagnóstico de metadatos de solo lectura sobre `sapo_db`, PostgreSQL 18.7, esquema `public`. El CSV contiene 798 filas de metadatos y no consulta registros de personas ni de incidentes. El primer contraste, realizado antes de incorporar las reglas adicionales al SQL versionado, obtuvo:

| Elemento contrastado | SQL candidato inicial | Instancia local | Resultado |
|---|---:|---:|---|
| Tablas | 24 | 24 | Coinciden los nombres |
| Columnas | 187 | 187 | Coinciden los nombres |
| Claves foráneas | 31 | 31 | Coinciden los nombres y las relaciones |
| Índices declarados explícitamente | 38 | 38 presentes | Todos los nombres del candidato aparecen en el catálogo |
| Índices del catálogo | — | 71 | Incluye índices asociados a claves primarias, restricciones `UNIQUE` y restricciones de exclusión |
| Triggers | 42 | 42 | Coinciden los nombres; difería un evento |
| Funciones propias (`fn_*`) | 36 nombres | 36 nombres | Coincidían los nombres; diferían tres implementaciones |

El catálogo de PostgreSQL informa de 248 rutinas en total, cifra que incluye funciones de PostgreSQL y de extensiones. Para la comparación del proyecto se aislaron las 36 funciones propias identificadas por el prefijo `fn_`. Las extensiones registradas son `btree_gist` 1.8 y `plpgsql` 1.0. La comparación de metadatos también encontró coincidencia en los nombres de columnas, su nulabilidad y las columnas declaradas como identidad `GENERATED ALWAYS`; el CSV no expone la longitud máxima de los tipos `VARCHAR`, por lo que ese detalle no se da por verificado.

### Reglas adicionales aceptadas para el modelo definitivo

Las diferencias de comportamiento detectadas en la instancia local se consideran coherentes con los objetivos de integridad, trazabilidad y conservación del histórico de S.A.P.O. Se adoptan como reglas del modelo global y ya se han incorporado al SQL versionado:

**ALERTA_TECNICA y ACTUACION_ALERTA**

- No se permite el borrado físico de alertas técnicas.
- Una alerta nueva comienza en estado `NUEVA`, sin fechas de resolución ni cierre; si se asigna responsable en el alta, debe ser un usuario activo.
- La identidad de la alerta es inmutable; una alerta cerrada no puede modificarse.
- El contador de ocurrencias y la fecha de última ocurrencia no pueden retroceder.
- Una vez asignado, el responsable no se puede sustituir ni retirar.
- Las fechas de resolución y cierre solo pueden establecerse mediante las transiciones correspondientes. Para resolver una alerta deben constar una acción correctiva y una verificación; el cierre exige resolución previa y observación final.

**AVISO_SEGUIMIENTO**

- Un aviso nuevo debe comenzar activo, en estado `PENDIENTE`, sin responsable ni fecha de gestión, y asociado a un incidente activo.
- La identidad del aviso, incluida su fecha de creación, es inmutable.
- Solo se pueden archivar avisos en estado terminal (`GESTIONADO` o `CANCELADO`) y sin alterar simultáneamente sus demás datos.
- Un aviso archivado permanece inmutable; solo puede reactivarse si estaba en estado terminal, se conservan sus datos y el incidente asociado continúa activo.
- No se permite el borrado físico de avisos; su retirada se representa mediante archivo.
- El inicio de la gestión requiere un usuario activo y la fecha de gestión se genera automáticamente.

**EJECUCION_PROCESO**

- No se permite eliminar ejecuciones.
- Toda ejecución comienza en `EN_EJECUCION` y sin `fecha_fin`.
- La identidad de la ejecución es inmutable.
- Solo se permiten las transiciones definidas hacia `COMPLETADA` o `FALLIDA`; al finalizar, `fecha_fin` se genera automáticamente.
- Una ejecución finalizada es inmutable.
- Una ejecución fallida debe conservar un detalle de error no vacío; los códigos de proceso y los identificadores, cuando se proporcionen, no pueden ser cadenas en blanco.

**Restricciones transversales añadidas**

- Las actuaciones de una alerta son append-only, deben tener una descripción no vacía y no pueden fecharse antes de la primera ocurrencia de la alerta.
- La última ocurrencia de una alerta no puede ser anterior a la primera. La fecha de resolución no puede ser anterior a la primera ocurrencia y la fecha de cierre no puede preceder a la resolución.
- Las fechas obligatorias de una alerta dependen de su estado: `NUEVA` y `EN_REVISION` no tienen fechas de resolución/cierre; `RESUELTA` tiene fecha de resolución y aún no de cierre; `CERRADA` tiene ambas.
- Una alerta resuelta solo admite el cierre formal y la observación final; no puede seguir cambiando su descripción, severidad, responsable ni contador de ocurrencias. La observación final solo se registra en el cierre.
- La fecha de gestión de un aviso no puede ser anterior a su creación. Las claves de deduplicación automáticas deben tener contenido no vacío y seguir siendo únicas.
- Los snapshots JSONB de auditoría, cuando existan, deben ser objetos JSON, coherentes con el uso de pares clave/valor para representar los campos modificados.
- Una persona archivada es inmutable; el cambio a estado archivado no puede combinarse con modificaciones de sus datos. Se permite la reactivación controlada cambiando únicamente `activo` y conservando todos los datos.
- Organización, usuario, persona, incidente, antecedente y ubicación se conservan mediante archivo lógico: el SQL impide su borrado físico. Las tablas de historial, catálogos protegidos, vinculaciones, asignaciones, documentos, avisos, ejecuciones, actuaciones y auditoría también cuentan con sus propias protecciones contra eliminación física.
- Un incidente o documento no puede combinar el archivo con cambios de sus datos operativos o contenido.
- La validación de altas de incidentes bloquea en modo compartido los catálogos cuya vigencia consulta. El cambio de estado bloquea primero la transición del catálogo y después los estados implicados, para evitar carreras con desactivaciones concurrentes.

Estas reglas pertenecen al modelo global de datos. Su aceptación no amplía por sí sola el alcance práctico comprometido para el Sprint 1 ni obliga a implementar ahora los módulos completos de alertas técnicas o gestión de procesos; se aplicarán cuando corresponda desarrollar esas partes del producto.

### Estado de la reconciliación

Las cuatro diferencias de comportamiento identificadas en el primer contraste ya se han incorporado al SQL versionado. Además, se ha adoptado una política coherente de conservación histórica que bloquea el borrado físico de organización, usuario, persona, incidente, antecedente y ubicación mediante una función común y seis triggers adicionales. El candidato consolidado contiene 24 tablas, 31 claves foráneas, 38 índices, 48 triggers, 41 sentencias de definición y 37 nombres de función distintos.

El fichero conserva el sufijo `CANDIDATO` hasta ejecutar y validar el esquema completo en una base de datos aislada y comparar de nuevo sus metadatos. La reconciliación documental y de reglas está realizada, pero no se declara todavía validación de ejecución ni equivalencia final de cada detalle de tipo de dato. La batería reproducible se encuentra en [`database/tests/TEST_REGLAS_INTEGRIDAD.sql`](../database/tests/TEST_REGLAS_INTEGRIDAD.sql), con instrucciones en [`database/tests/README.md`](../database/tests/README.md); está preparada, pero aún no se ha ejecutado. No ejecutar el candidato sobre `sapo_db`, ni usarlo para recrear o sustituir la instancia local.

El CSV contiene metadatos del esquema, no filas de las tablas de catálogo. Por tanto, no permite identificar la procedencia ni comprobar el contenido de la organización y de los siete tipos de incidente que ya existen localmente; ese trabajo continúa en la [tarea #51](https://github.com/Zanguango/SAPO/issues/51).

### Datos iniciales que aporta el script

El script incluye tres bloques de inserción: los perfiles base, los estados de incidente y las transiciones permitidas. No incluye altas iniciales de `ORGANIZACION` ni de `TIPO_INCIDENTE`; tampoco incluye personas ni incidentes de demostración. La creación de los registros locales conocidos (una organización y siete tipos de incidente) debe resolverse mediante la [tarea #51](https://github.com/Zanguango/SAPO/issues/51). Las semillas deben usar claves de negocio/códigos, ser idempotentes y probarse en una base aislada.

### Auditoría y temporización del proceso automático

La tabla `AUDITORIA` almacena usuario/origen, entidad, identificador del registro, acción, valores anteriores/nuevos en JSONB y `fecha_evento`. El trigger definido para esta tabla protege la inmutabilidad de eventos ya insertados frente a `UPDATE` y `DELETE`; el SQL no crea automáticamente eventos de auditoría ni contiene sentencias `INSERT INTO AUDITORIA`. Por tanto, el backend debe registrar explícitamente las acciones relevantes.

Para que SAPO-018 y SAPO-019 determinen cuánto tiempo lleva una incidencia en estado `PENDIENTE`, el backend debe insertar un evento `STATE_CHANGE` cada vez que cambia su estado, dentro de la misma transacción que actualiza `INCIDENTE`. El evento debe identificar `entidad='INCIDENTE'` e `id_registro`. Se acuerda usar la clave JSON `estado` en ambos snapshots: `valores_anteriores = {"estado":"EN_GESTION"}` y `valores_nuevos = {"estado":"PENDIENTE"}` (los códigos concretos dependerán del estado de origen). El campo `fecha_evento` será la marca temporal. La consulta del proceso tomará el último evento cuyo `valores_nuevos ->> 'estado'` sea `PENDIENTE`, siempre que el estado actual de la incidencia siga siendo pendiente. No debe utilizar `fecha_modificacion` general como sustituto, porque puede cambiar por otras ediciones.

El esquema ya dispone de:
- `CONFIGURACION_UMBRAL` para almacenar los valores/versiones de umbral;
- `AVISO_SEGUIMIENTO.clave_deduplicacion` con índice único parcial para impedir avisos duplicados;
- `EJECUCION_PROCESO.identificador_ejecucion` con índice único parcial para evitar duplicar la misma ejecución.

Estas capacidades de persistencia no implementan por sí solas el scheduler: la planificación periódica, la consulta del último cambio de estado, la creación idempotente del aviso y el cierre del registro de ejecución corresponden al backend.

## 11. Evolución del modelo

Este esquema constituye la base de datos de partida del proyecto. Si durante los siguientes sprints aparecen nuevas necesidades funcionales o correcciones del profesor, revisaré el modelo y registraré los cambios mediante el procedimiento de control de cambios de la asignatura. No ampliaré ni modificaré el esquema sin relacionar el ajuste con un requisito, historia o incidencia concreta.
