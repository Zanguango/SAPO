# Diseño de la base de datos de S.A.P.O.

**Proyecto:** Sistema Avanzado Policial Operativo  
**Asignatura:** Proyecto de Ingeniería de Software (47GIIN)  
**Autor:** Ignacio Teruel Cuartero  
**Base de datos:** PostgreSQL 18.7  
**Base local:** `sapo_db` · esquema `public`

## 1. Finalidad del modelo

Este documento es la referencia documental única del diseño de la base de datos de S.A.P.O. El modelo relacional fue preparado antes del Sprint 1 para dar soporte al producto completo y relacionar personas, antecedentes, incidencias, usuarios, perfiles, organización, auditoría y procesos de seguimiento.

Durante el Sprint 1 no se creó ni se volvió a ejecutar el esquema: se revisó el modelo existente, se delimitó su aplicación al circuito práctico y se documentaron sus relaciones y dependencias. Para la implementación práctica, el circuito prioritario se centra en registrar y consultar incidencias ficticias asociadas a personas. El resto de entidades forman parte del modelo global y se incorporarán funcionalmente solo cuando correspondan al alcance aprobado.

La base utiliza claves primarias, claves foráneas, restricciones, índices y mecanismos de integridad para mantener la coherencia entre los registros. La revisión del diseño relacional se conserva en el repositorio como [SQL candidato versionado](../database/schema/SAPO_CORREGIDO_REVISION_ESTATICA_CANDIDATO.sql). El contraste de metadatos con la instancia local `sapo_db` ha confirmado coincidencias estructurales, pero también diferencias de comportamiento en determinadas funciones y triggers. Por ello, el candidato es una referencia de diseño y contraste, no una copia certificada del esquema instalado ni un script para recrear la base local.

## 2. Estructura general

La estructura implementada en el script de referencia contiene:

| Elemento | Cantidad |
|---|---:|
| Tablas | 24 |
| Claves foráneas | 31 |
| Índices | 38 |
| Triggers | 42 |
| Sentencias `CREATE OR REPLACE FUNCTION` | 40 |
| Nombres de función distintos en el script | 36 |

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

El script contiene cuatro redefiniciones de función mediante `CREATE OR REPLACE`: `fn_proteger_historial_organizativo`, `fn_validar_aviso_seguimiento`, `fn_validar_alerta_tecnica` y `fn_proteger_version_umbral`. Por eso, el recuento de 40 sentencias no equivale a 40 funciones distintas: el script deja 36 nombres de función diferentes.

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

El modelo relacional evolucionó desde un diseño anterior hacia una revisión que incorporó cuatro ajustes de consistencia:

- Retirada de una cláusula `FOR UPDATE` situada dentro de un `EXISTS` de validación de transiciones, donde no era válida.
- Separación de las validaciones de alta y reactivación de las vinculaciones persona–incidente, comprobando que la persona y el incidente estén activos y que el incidente no se encuentre en un estado terminal.
- Protección de los documentos archivados frente a modificaciones.
- Ampliación de la validación de las ejecuciones de proceso para que también se compruebe su alta (`INSERT`).

La versión SQL revisada se conserva como [candidato versionado](../database/schema/SAPO_CORREGIDO_REVISION_ESTATICA_CANDIDATO.sql). Su inventario estático contiene 24 tablas, 31 claves foráneas, 38 índices declarados mediante `CREATE INDEX`, 42 triggers y 40 sentencias `CREATE OR REPLACE FUNCTION`, que corresponden a 36 nombres de función distintos porque cuatro se redefinen.

### Resultado del contraste con `sapo_db` (26/11/2026)

Se ejecutó el diagnóstico de metadatos de solo lectura sobre `sapo_db`, PostgreSQL 18.7, esquema `public`. El CSV obtenido contiene 798 filas de metadatos y no consulta los registros de personas ni de incidentes.

| Elemento contrastado | SQL candidato | Instancia local | Resultado |
|---|---:|---:|---|
| Tablas | 24 | 24 | Coinciden los nombres |
| Columnas | 187 | 187 | Coinciden los nombres |
| Claves foráneas | 31 | 31 | Coinciden los nombres y las relaciones |
| Índices declarados explícitamente | 38 | 38 presentes | Todos los nombres del candidato aparecen en el catálogo |
| Índices del catálogo | — | 71 | Incluye índices asociados a claves primarias, restricciones `UNIQUE` y restricciones de exclusión |
| Triggers | 42 | 42 | Coinciden los nombres; hay una diferencia de eventos |
| Funciones propias (`fn_*`) | 36 nombres | 36 nombres | Coinciden los nombres; difieren tres implementaciones |

El catálogo de PostgreSQL informa de 248 rutinas en total, cifra que incluye funciones de PostgreSQL y de extensiones. Para la comparación del proyecto se han aislado las 36 funciones propias identificadas por el prefijo `fn_`. Las extensiones registradas son `btree_gist` 1.8 y `plpgsql` 1.0. La comparación de metadatos también encuentra coincidencia en los nombres de columnas, su nulabilidad y las columnas declaradas como identidad `GENERATED ALWAYS`; el CSV no expone la longitud máxima de los tipos `VARCHAR`, por lo que ese detalle no se da por verificado con este resultado.

### Diferencias de comportamiento detectadas

La equivalencia no es completa. La instancia local contiene validaciones adicionales que no aparecen en el SQL candidato:

- **`trg_validar_alerta_tecnica`:** en la base local se dispara ante `INSERT`, `UPDATE` y `DELETE`; en el candidato solo ante `INSERT` y `UPDATE`. La implementación local impide la eliminación física de alertas técnicas.
- **`fn_validar_alerta_tecnica`:** la versión local incorpora la prohibición de borrado físico y validaciones adicionales sobre la identidad de la alerta, su cierre, la evolución de ocurrencias y la asignación del responsable.
- **`fn_validar_aviso_seguimiento`:** la versión local exige que un aviso nuevo se cree activo y restringe la reactivación de avisos archivados, preservando sus datos y permitiendo únicamente la reactivación de avisos terminales bajo esas condiciones.
- **`fn_validar_ejecucion_proceso`:** la versión local hace inmutables las ejecuciones finalizadas, limita las transiciones permitidas y asigna automáticamente `fecha_fin` al completar o fallar una ejecución.

Por tanto, el resultado de la comparación es **equivalencia parcial con diferencias enumeradas**. La instancia local y el candidato comparten el inventario principal de objetos, pero el candidato no reproduce exactamente las reglas de integridad que están instaladas. No ejecutar el candidato sobre `sapo_db`, ni usarlo para recrear o sustituir la instancia. Antes de convertirlo en referencia canónica de despliegue habrá que reconciliar estas diferencias, conservar las reglas que se decidan y validar el resultado en una base aislada.

El CSV contiene metadatos del esquema, no filas de las tablas de catálogo. Por tanto, no permite identificar la procedencia ni comprobar el contenido de la organización y de los siete tipos de incidente que ya existen localmente; ese trabajo continúa en la [tarea técnica #51](https://github.com/Zanguango/SAPO/issues/51).

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
