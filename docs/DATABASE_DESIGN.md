# Diseño de la base de datos de S.A.P.O.

**Proyecto:** Sistema Avanzado Policial Operativo  
**Asignatura:** Proyecto de Ingeniería de Software (47GIIN)  
**Autor:** Ignacio Teruel Cuartero  
**Base de datos:** PostgreSQL 18.7  
**Base local:** `sapo_db` · esquema `public`

## 1. Finalidad del modelo

He diseñado la base de datos para dar soporte al producto S.A.P.O. como sistema de información relacional. El modelo contempla las entidades del producto completo y permite relacionar personas, antecedentes, incidencias, usuarios, perfiles, organización, auditoría y procesos de seguimiento.

Para la implementación práctica de la asignatura, el circuito prioritario se centra en registrar y consultar incidencias ficticias asociadas a personas. El resto de entidades forman parte del modelo global y se incorporarán funcionalmente solo cuando correspondan al alcance aprobado.

La base utiliza claves primarias, claves foráneas, restricciones, índices y mecanismos de integridad para mantener coherencia entre los registros. El script SQL de referencia del diseño es `SAPO_CORREGIDO_REVISION_ESTATICA.sql`.

## 2. Estructura general

La estructura implementada en el script de referencia contiene:

| Elemento | Cantidad |
|---|---:|
| Tablas | 24 |
| Claves foráneas | 31 |
| Índices | 38 |
| Triggers | 42 |
| Definiciones de funciones PL/pgSQL | 40 |

La base separa los datos principales, los catálogos, las relaciones entre entidades y los elementos de trazabilidad. Los identificadores se generan en la base de datos y las relaciones se protegen mediante claves y restricciones.

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

La relación entre personas e incidentes es de muchos a muchos y se resuelve mediante `VINCULACION_PERSONA_INCIDENTE`. Así puedo asociar varias personas a un incidente y una persona a distintos incidentes, conservando el tipo de vinculación correspondiente.

## 4. Entidades de soporte y trazabilidad

El modelo completo incorpora también entidades para usuarios y perfiles, historial de asignación de perfiles, historial de pertenencia organizativa, antecedentes y sus tipos, documentos asociados, asignaciones, auditoría, ejecución de procesos, alertas y configuración de seguimiento.

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

El requisito de normalización no se da por acreditado solo por contar tablas y relaciones. Dejaré una justificación formal de las tres primeras formas normales como evidencia de diseño, revisando dependencias funcionales, claves candidatas y atributos de cada relación.

El modelo de datos tampoco implica que la API, la interfaz, los CRUD, los informes, las estadísticas o el proceso automatizado estén implementados. Esas funcionalidades se desarrollarán y verificarán en las iteraciones correspondientes.

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

Los recuentos locales de tablas y claves foráneas coinciden con el diseño SQL de referencia. Esta comprobación valida esos recuentos, pero no equivale a comparar individualmente cada objeto de la instancia con el script.

Los siete tipos de incidente aparecen con fecha de creación 17/11/2026 a las 18:48:43 aproximadamente, anterior al inicio del Sprint 1. La consulta de recuento confirma que existe una organización, pero todavía debo recuperar el origen de su alta y de los tipos de incidente para poder reproducirlos desde una base vacía.

## 9. Datos iniciales y reproducibilidad

He separado el diseño del esquema de los datos de demostración. Los catálogos de estados y transiciones ya están incluidos en el script. La organización y los tipos de incidente ya existen en mi instancia local, pero debo identificar el mecanismo que los creó.

No volveré a insertar esos registros ni a recrear la base hasta localizar su origen o preparar una carga equivalente que:
- use datos exclusivamente ficticios;
- respete claves y restricciones;
- no escriba manualmente identificadores de identidad;
- pueda repetirse sin duplicar registros;
- se pruebe primero en una base aislada.

La estrategia y la tarea pendiente están en [database/seeds/README.md](../database/seeds/README.md) y en la [tarea técnica #51](https://github.com/Zanguango/SAPO/issues/51).

## 10. Evolución del modelo

Este esquema constituye la base de datos de partida del proyecto. Si durante los siguientes sprints aparecen nuevas necesidades funcionales o correcciones del profesor, revisaré el modelo y registraré los cambios mediante el procedimiento de control de cambios de la asignatura. No ampliaré ni modificaré el esquema sin relacionar el ajuste con un requisito, historia o incidencia concreta.
