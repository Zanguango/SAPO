# Línea base del proyecto y decisiones de S.A.P.O.

**Proyecto:** S.A.P.O. — Sistema Avanzado Policial Operativo  
**Asignatura:** Proyecto de Ingeniería de Software (47GIIN) — VIU  
**Responsable:** Ignacio Teruel Cuartero  
**Revisión de coherencia:** 27/11/2026  
**Repositorio:** https://github.com/Zanguango/SAPO  
**Tablero:** https://github.com/users/Zanguango/projects/1

Este documento consolida las fuentes rectoras, el alcance aprobado, las decisiones técnicas y las pautas de trabajo acordadas. Se utiliza como punto de recuperación al continuar el proyecto en otra conversación. No sustituye a la propuesta aprobada, al Product Backlog ni a los documentos específicos de cada sprint.

## 1. Fuentes rectoras y orden de prevalencia

Cuando dos documentos parezcan contradecirse, aplicar este orden:

1. **Requisitos oficiales de la asignatura:** `2024-25_47GIIN - Requisitos implementación(1).pdf`. Exigen arquitectura, modelo completo en al menos 1FN–3FN, modelado de interfaces del 50 % del producto, modelado de reportes, alrededor de 15 CRUD en la arquitectura global, gestión de acceso, auditoría y backups descritos, y para la implementación del 20 % al menos un circuito CRUD, tres CRUD básicos, CRUD de datos generales de organización, un proceso automatizado, inicio de sesión/permisos, dos reportes, persistencia y una estadística.
2. **Propuesta final entregada:** `47GIIN_IgnacioTeruelCuartero_PropuestaFinalFinal(1).pdf`, fechada el 10/11/2026. Es la referencia principal para el alcance funcional seleccionado, restricciones y planificación inicial.
3. **Evaluación de la propuesta en segunda instancia:** `Evaluación de la propuesta - segunda instancia - 12-11-2026.pdf`. Resultado: APROBADO. Observación del profesor: las funcionalidades que dependan de otras entidades deben disponer de datos vinculados mediante algún mecanismo. Esto exige preparar datos ficticios iniciales y reproducibles.
4. **Planificación definitiva del Sprint 1:** `SAPO_Planificacion_Sprint_1_Definitiva.pdf`, periodo 19–30/11/2026, 14 horas y cuatro historias. Esta versión sustituye las fechas anteriores de Sprint 1 de la propuesta.
5. **Instrucciones de planificación y cierre:** `47GIIN - Sobre la planificación y cierre de las iteraciones.pdf`, junto con `47GIIN - Modelo de informe de avance.docx`.
6. **Documentación operativa del repositorio:** `docs/PROJECT_BASELINE.md` (línea base de continuidad), `docs/PRODUCT_BACKLOG.md`, `docs/DATABASE_DESIGN.md`, planificación, registro de trabajo, arquitectura, entorno, seguridad y semillas.
7. **Histórico del Product Backlog del 17/11/2026:** `SAPO_Product_Backlog.xlsx`, `SAPO_Product_Backlog.csv` y `SAPO_Product_Backlog_Entrega.pdf` son snapshots históricos y no la fuente vigente. El Excel/CSV y el PDF no coinciden en varios campos de alcance; la propuesta aprobada, los requisitos oficiales y el Product Backlog actual prevalecen.
8. **Prototipo anterior:** `sapo.zip` contiene un frontend y un backend antiguos basados en SQLite. Es referencia histórica, no la arquitectura vigente PostgreSQL/Node.js prevista para 47GIIN. El RAR de la actividad 45GIIN no se ha vuelto a extraer en esta revisión.

La propuesta describe un plan inicial de sprints hasta enero de 2027. Como el Sprint 1 se replanificó y quedó aprobado para el 19–30 de noviembre, las fechas posteriores deben revisarse y aprobarse de nuevo. No se deben copiar automáticamente las fechas antiguas ni solapar iteraciones.

## 2. Naturaleza y límites del producto

S.A.P.O. es exclusivamente un **prototipo académico de un escenario simulado**:

- Usar solo datos ficticios.
- No conectar con sistemas policiales, judiciales o administrativos reales.
- No utilizar ni almacenar datos reales, clasificados o información operativa auténtica.
- No utilizar geolocalización real, biometría, reconocimiento facial ni consultas a bases externas.
- No enviar comunicaciones externas desde el proceso automático.
- No desplegar en producción ni presentarlo como sistema operativo institucional.
- «Avanzado» significa integración funcional de información, roles, trazabilidad, consultas e informes; no implica IA ni predicción.

## 3. Interpretación obligatoria del alcance

**Distinguir el alcance del proyecto del sprint en curso.**

- **Incremento** significa que la funcionalidad forma parte del prototipo que debe entregarse en 47GIIN. Puede implementarse en el Sprint 2, 3, 4 o 5; no deja de estar comprometida por no haberse trabajado en el Sprint 1.
- **Futuro** significa que la funcionalidad queda fuera del incremento comprometido para esta asignatura y se conserva como visión del producto completo.
- **Incremento condicionado** solo debe usarse cuando la propuesta supedita expresamente la funcionalidad a que resulte necesaria o se justifique.
- Una historia marcada como `Futuro` no debe utilizarse para representar simplemente «todavía no iniciada» o «programada para un sprint posterior».
- La planificación del sprint solo asigna parte del Product Backlog a una iteración; no cambia por sí sola el alcance global.

Por tanto, los siguientes elementos **sí forman parte del prototipo de 47GIIN aunque se implementen en sprints posteriores**: CRUD básico de datos generales de la organización, proceso automático de seguimiento, dos reportes y una estadística.

## 4. Alcance funcional mínimo comprometido

La selección del apartado 8 de la propuesta final establece el siguiente incremento aproximado del 20 %:

| Área | Resultado mínimo comprometido | Historias relacionadas |
|---|---|---|
| Personas | Crear, listar, consultar por identificador y modificar personas ficticias. | SAPO-006, 007, 008 |
| Incidentes | Crear, listar, consultar y actualizar estado de incidencias ficticias asociadas a personas. | SAPO-012, 013, 014, 015, 016 |
| Autenticación | Inicio de sesión y comprobación de permisos básicos con al menos dos perfiles de prueba. | SAPO-004, 005 |
| Persistencia | PostgreSQL para el circuito y datos iniciales ficticios relacionados. | SAPO-002, 003 y tarea técnica #51 |
| Organización | CRUD mínimo de los datos generales ficticios de la organización usados en cabeceras e informes. No equivale a administrar todas las unidades organizativas. | SAPO-017 |
| Automatización | Tarea programada que detecta incidencias pendientes tras un umbral configurable y crea avisos de seguimiento sin duplicados. Debe registrar la ejecución y no enviar comunicaciones externas. | SAPO-018, 019 |
| Reporte 1 | Listado de incidencias por periodo y estado, con filtros básicos. | SAPO-020 |
| Reporte 2 | Informe de actividad por tipo de incidente, con detalle consultable de la incidencia, las personas vinculadas y los datos de seguimiento permitidos. | SAPO-021 y SAPO-016 |
| Estadística 1 | Conteo agregado de incidencias por tipo o estado en un periodo. | SAPO-022 |
| Auditoría mínima | Registrar acciones relevantes de los flujos implementados con usuario/origen, fecha, operación y entidad. La consulta del histórico completo queda como evolución futura. | SAPO-023 |
| Verificación | Pruebas unitarias, de integración y funcionales con datos ficticios, incluida la ejecución repetida del proceso y la comprobación de que no duplica avisos. | SAPO-027 |
| Respaldo | Describir cómo se contemplan los backups y realizar la prueba de restauración en una base aislada indicada en la propuesta. No se exige una plataforma empresarial automatizada. | SAPO-029 |
| Documentación y seguridad | Guía reproducible de entorno/ejecución y controles básicos de privacidad, secretos, autenticación, permisos y errores. | SAPO-028, 030 |

### Aclaración sobre auditoría, antecedentes y backups

- **SAPO-010 — Consulta de antecedentes:** `Incremento condicionado`; solo se implementa si es necesaria para completar el circuito práctico. El CRUD completo de antecedentes queda fuera.
- **SAPO-023 — Auditoría mínima:** `Incremento`; se registran las acciones relevantes de los flujos comprometidos.
- **SAPO-024 — Consulta del histórico completo de auditoría:** `Futuro`; queda fuera del mínimo del 20 %. El requisito de auditoría se cubre mediante registro mínimo de acciones, y la propuesta plantea la consulta restringida como parte del diseño completo.
- **SAPO-029 — Backups:** la asignatura exige describirlos y la propuesta incorpora un escenario de prueba de backup/restauración en una instancia aislada. El compromiso es documentar y demostrar esta prueba, no desarrollar un servicio empresarial de backup automatizado.

### Aclaración sobre los dos reportes

La propuesta describe en el apartado de módulos un reporte de incidentes por periodo y estado y otro de actividad por tipo; en la tabla de selección del 20 % define el segundo como detalle de incidente con personas vinculadas y datos de seguimiento. Para conservar ambos criterios sin crear un tercer reporte, el segundo reporte se diseñará como **actividad agrupada por tipo con acceso al detalle de cada incidencia y sus personas/seguimiento permitido**. Esta interpretación debe conservarse en las historias, interfaces, pruebas y demostración.

## 6. Los 15 CRUD de la arquitectura global

La propuesta enumera 15 entidades CRUD para la arquitectura completa. Esto **no significa que deban implementarse los 15 CRUD completos** dentro del 20 % práctico. La selección mínima de la sección anterior delimita qué operaciones y módulos se entregan en la asignatura.

Los 15 CRUD globales son: Personas; Antecedentes; Incidentes; Usuarios; Perfiles; Datos de organización; Unidades organizativas; Tipos de incidente; Estados de incidente; Tipos de antecedente; Ubicaciones simuladas; Avisos de seguimiento; Documentos asociados; Vinculaciones persona–incidente; y Asignaciones de incidentes.

No contar Create, Read, Update y Delete como cuatro CRUD independientes: el conjunto de operaciones sobre una entidad es un CRUD. En las entidades que requieren trazabilidad, se prefiere archivado lógico frente a borrado físico.

## 7. Diseño de base de datos y decisiones técnicas

### Referencia documental y trabajo previo

- `docs/DATABASE_DESIGN.md` es el único documento descriptivo de diseño de la base de datos. No crear documentos paralelos por sprint que dupliquen el modelo.
- La preparación y primera ejecución del esquema SQL de S.A.P.O. son trabajo previo al Sprint 1. No volver a contabilizarlos como trabajo del Sprint 1 o de futuros sprints.
- Toda historia futura que reutilice el esquema debe enlazar `docs/DATABASE_DESIGN.md` y la evidencia existente, sin narrar de nuevo la creación del esquema.
- Los cambios futuros del esquema deben tener requisito/historia, justificación, script versionado y trazabilidad de control de cambios.

### Modelo existente

El esquema SQL canónico contiene 24 tablas, 31 claves foráneas, 38 índices explícitos y 48 triggers; sus 41 sentencias `CREATE OR REPLACE FUNCTION` corresponden a 37 nombres propios distintos. El diagnóstico de solo lectura exportado desde `sapo_db` el 26/11/2026 (PostgreSQL 18.7) registra 24 tablas, 187 columnas, 31 claves foráneas, 71 índices de catálogo, 42 triggers y 36 funciones propias (`fn_*`). Las 38 denominaciones de índices explícitos del diseño inicial aparecen en la instancia. Los 71 índices de catálogo incluyen también los generados por claves primarias y restricciones de unicidad/exclusión. El catálogo recoge 248 rutinas en total, incluidas las de PostgreSQL y extensiones. La instancia registra las extensiones `btree_gist` 1.8 y `plpgsql` 1.0.

El primer contraste identificó cuatro diferencias de comportamiento en un trigger y tres funciones. Se aceptaron las protecciones locales como reglas del modelo global y se incorporaron al esquema SQL canónico validado: bloqueo del borrado físico y mayor control del ciclo de vida de alertas técnicas; reglas para creación, archivo y reactivación de avisos; e inmutabilidad y finalización controlada de ejecuciones de proceso. Estas decisiones no amplían por sí mismas el alcance práctico del Sprint 1. El esquema canónico se ha instalado desde cero y ha superado las pruebas automáticas en PostgreSQL 18.7, ejecución [#6](https://github.com/Zanguango/SAPO/actions/runs/45885898980). No se ha ejecutado sobre `sapo_db`; su posible actualización queda separada en la [tarea #56](https://github.com/Zanguango/SAPO/issues/56).

### Decisiones de dominio y modelo

- Las claves primarias se generan mediante `GENERATED ALWAYS AS IDENTITY`; nunca fijar manualmente sus valores en seeds.
- La relación Persona–Incidente es N:M mediante `VINCULACION_PERSONA_INCIDENTE`.
- Una persona puede aparecer en diferentes incidentes y un incidente puede vincular varias personas, cada una con su tipo de vinculación.
- El SQL enumera los tipos de vinculación: `VICTIMA`, `AFECTADO`, `PERJUDICADO`, `DENUNCIANTE`, `TESTIGO`, `INVESTIGADO`, `DETENIDO`, `PRESUNTO_AUTOR`, `REPRESENTANTE`, `SOLICITANTE`, `AGENTE_ACTUANTE` y `OTRO`.
- Los estados acordados de antecedentes son `PENDIENTE`, `VIGENTE` y `ANULADO`.
- El modelo global contiene tres perfiles base protegidos: `ADMINISTRADOR`, `SUPERVISOR` y `AGENTE`. La implementación práctica requiere al menos dos perfiles de prueba con permisos distintos; no implica construir el CRUD completo de administración de usuarios/perfiles.
- La auditoría de cambios debe conservar valores anteriores y posteriores de los campos modificados cuando corresponda, excluyendo contraseñas, tokens, secretos y datos sensibles innecesarios.
- En la política funcional global acordada, el perfil AGENTE tiene un acceso más limitado; las consultas de antecedentes no deben quedar abiertas por defecto. Los permisos efectivos se verificarán en backend, no solo ocultando opciones en el frontend.

### SQL y reproducibilidad

El diseño del esquema evolucionó desde una definición anterior hacia una revisión posterior, disponible en `database/schema/SAPO_SCHEMA.sql`. Además de los ajustes de consistencia en transiciones, vinculaciones persona–incidente y documentos, se han adoptado e incorporado reglas de integridad para alertas técnicas, avisos de seguimiento y ejecuciones de proceso. También se añadieron controles cronológicos para actuaciones, alertas y avisos; campos de texto no vacíos en datos críticos; validación de claves de deduplicación y estructura de snapshots JSONB. Se bloqueó el borrado físico de avisos y de las entidades con archivo lógico (organización, usuario, persona, incidente, antecedente y ubicación), se reforzó la inmutabilidad y restauración controlada de personas archivadas y se separó el archivado de incidentes/documentos de cualquier cambio de contenido. Además, se ajustaron bloqueos de filas para serializar comprobaciones de vigencia y transiciones frente a operaciones concurrentes.

El primer contraste y las reglas aceptadas están documentados en `docs/DATABASE_DESIGN.md`. El esquema canónico `database/schema/SAPO_SCHEMA.sql` se creó desde una base vacía en PostgreSQL 18.7 y superó la batería reproducible `database/tests/TEST_REGLAS_INTEGRIDAD.sql` mediante GitHub Actions, ejecución [#6](https://github.com/Zanguango/SAPO/actions/runs/45885898980). La validación no modificó `sapo_db`; cualquier actualización de la instancia local requiere un análisis y una migración independiente.

El SQL incluye los registros iniciales de tres perfiles, cuatro estados y cinco transiciones. La instancia local también tiene una organización y siete tipos de incidente, pero su procedencia debe recuperarse o reproducirse mediante la tarea técnica [#51](https://github.com/Zanguango/SAPO/issues/51).

Las cargas iniciales deben:
- contener exclusivamente datos ficticios;
- respetar las claves foráneas y el orden de dependencias;
- resolverse por claves de negocio/códigos, no por IDs escritos a mano;
- poder repetirse sin duplicar datos;
- ejecutarse primero en una base aislada;
- no alterar la instancia local actual durante la investigación.

### Dos decisiones técnicas que deben verificarse al implementar

1. El proceso automático necesita conocer desde cuándo una incidencia permanece en estado `PENDIENTE`. Usar un evento de cambio de estado trazable o un dato específico de inicio del estado; no utilizar sin justificar `fecha_modificacion` general, ya que otras modificaciones podrían reiniciar el umbral.
2. El esquema contiene campos `JSONB` en auditoría y ejecución de procesos. La justificación formal de 1FN–3FN debe explicar su naturaleza y atomicidad o proponer una descomposición relacional si esos campos almacenan grupos de atributos.
3. El SQL no inserta automáticamente eventos en `AUDITORIA`: define la tabla, sus restricciones/índices y un trigger que impide modificar o borrar eventos ya insertados, pero no un trigger que los cree. El backend deberá registrar los eventos dentro de la misma transacción que la operación auditada.
4. `INCIDENTE` no contiene una fecha específica de entrada en el estado actual ni una tabla relacional de historial de estados. Para el proceso automático se utilizará `AUDITORIA` como historial de transiciones: cada cambio de estado realizado por la API deberá insertar un evento `STATE_CHANGE` con `entidad='INCIDENTE'`, `id_registro`, el código de estado anterior en `valores_anteriores` y el código nuevo en `valores_nuevos`. El evento debe insertarse en la misma transacción que el cambio. El proceso calculará la antigüedad en `PENDIENTE` a partir del último evento cuyo nuevo estado sea `PENDIENTE`; no usará `fecha_modificacion` general.

## 8. Requisitos de diseño pendientes de acreditar

La asignatura exige:
- arquitectura con componentes e interacciones;
- modelo de datos completo del producto en al menos 1FN, 2FN y 3FN;
- modelado de interfaces del 50 % del producto;
- modelado de las salidas/reportes.

El Sprint 1 dejó documentada la arquitectura inicial y el diseño general, pero quedan como tareas explícitas:
- justificar formalmente 1FN, 2FN y 3FN para el modelo completo de 24 tablas, con claves y dependencias funcionales;
- modelar al menos el 50 % de las pantallas del producto y las salidas correspondientes a los dos reportes y la estadística;
- mantener las decisiones anteriores alineadas con el SQL, las historias y las pruebas.

Estas tareas quedan registradas en el Product Backlog como SAPO-031 y SAPO-032.

## 9. Organización del trabajo y entregables de cada sprint

Se aplica Scrum adaptado al trabajo individual (Single Scrum), con GitHub Projects para seguimiento y GitHub para control de versiones.

Cada sprint debe durar entre 7 y 21 días. Para planificar una iteración, el PDF debe incluir:
- objetivo narrativo;
- incremento esperado;
- fechas y plazos;
- Sprint Backlog con historias;
- descomposición en tareas técnicas y estimación de esfuerzo en horas.

En el texto anexo se incluyen los enlaces al tablero y al repositorio.

Para cerrar una iteración se entrega:
- informe PDF de avance que identifique lo realizado, problemas/dificultades y tareas de la siguiente iteración;
- planificación detallada de la iteración siguiente dentro del mismo PDF;
- vídeo de avances de máximo cinco minutos y enlace accesible;
- enlace al repositorio y evidencias de los trabajos.

La plantilla oficial del informe de avance requiere incluir: número de informe, fecha, iteración, enlaces al tablero y repositorio, enlace al vídeo cuando el informe es de cierre, porcentaje de avance global, avances desde el informe anterior, problemas e impacto y avances previstos para las próximas semanas. En los informes parciales no se exige aún el enlace al vídeo de cierre.

La plantilla de solicitud de cambios debe replicarse para cada cambio: fecha de presentación, módulo afectado, motivo, descripción detallada, estado previo, estado posterior y justificación. Cualquier cambio material de alcance, requisitos o diseño debe seguir este procedimiento del aula virtual y actualizar backlog, issue, documentación y planificación cuando corresponda.

Cada historia debe tener criterios de aceptación verificables. Cada tarea debe tener estimación de esfuerzo, resultado y evidencia. No se asignan fechas retrospectivas a trabajos anteriores ni se declara funcional una capa que solo está documentada.

## 10. Estado de referencia a 27/11/2026

- Propuesta final: entregada el 10/11/2026.
- Evaluación de la propuesta en segunda instancia: APROBADO el 12/11/2026, con observación sobre disponer de datos de entidades vinculadas.
- Sprint 1: planificación definitiva del 19 al 30/11/2026, 14 horas; planificación aprobada por el profesor el 26/11/2026.
- Historias de Sprint 1 marcadas Done en GitHub: SAPO-001, SAPO-003, SAPO-028 y SAPO-030.
- Cierre formal del Sprint 1: pendiente del 30/11/2026, con informe PDF, planificación de la siguiente iteración y vídeo de máximo cinco minutos.
- Tarea técnica #51: abierta, para recuperar/reproducir la organización y los siete tipos de incidente sin duplicarlos.
- Tarea técnica #54: cerrada tras comparar el primer estado estructural de `sapo_db` con el diseño anterior.
- Tarea técnica #56: abierta para comparar la instancia local con el esquema canónico validado y decidir, sin modificarla, si procede una migración controlada.
- Diagnóstico ampliado de #56: el script de solo lectura actualizado se validó en CI [#10](https://github.com/Zanguango/SAPO/actions/runs/45886924060) y [#11](https://github.com/Zanguango/SAPO/actions/runs/45887074799). El CSV nuevo, recibido el 27/11, confirma 24 tablas, 187 columnas, 31 FK, 71 índices, 40 CHECK, 42 triggers y 36 funciones propias. Las 187 columnas coinciden en tipo, longitudes, precisión, nulabilidad e identidad; los 38 índices explícitos y los valores por defecto también coinciden. Diferencias: faltan 10 CHECK, seis triggers de borrado físico y `fn_bloquear_eliminacion_fisica`; dos CHECK son menos restrictivas, dos triggers tienen eventos distintos y hay diferencias funcionales en reglas de archivo, alertas, avisos, actuaciones y bloqueos de concurrencia. Todo está documentado en `docs/DATABASE_DESIGN.md`. Se ha creado también `database/diagnostics/VERIFICAR_COMPATIBILIDAD_DATOS_PRE_MIGRACION_SOLO_LECTURA.sql`, validado en CI #13 con cero filas infractoras en el esquema vacío de prueba. Falta ejecutarlo sobre `sapo_db`, revisar la salida y después ensayar una migración incremental sobre una copia restaurada. `sapo_db` sigue intacta.
- Node.js, npm, Git y el cliente `psql`: no reconocidos como comandos en CMD en las comprobaciones del 26/11; instalar o corregir PATH antes de desarrollar el backend.
- Backend, frontend y conexión Node.js/Express–PostgreSQL: todavía no implementados.
- Base de datos local: no recrear ni alterar para resolver la trazabilidad del esquema/seeds.

## 11. Pautas de continuidad

Antes de cambiar cualquier documento, issue o componente:
1. comprobar este documento y la propuesta aprobada;
2. identificar si el cambio altera alcance, diseño, sprint o solo documentación;
3. conservar el trabajo previo al Sprint 1 separado de la evidencia de cada sprint;
4. actualizar coherentemente Product Backlog, issue GitHub, documentación técnica y criterios de prueba;
5. enlazar evidencia existente si se reutiliza trabajo previo;
6. registrar cualquier cambio de alcance mediante el procedimiento del aula virtual;
7. comprobar la estructura real del repositorio y no describir como existente lo que todavía está pendiente;
8. mantener el uso exclusivo de datos ficticios y la prohibición de conexiones reales.

**Regla central:** la propuesta aprobada define qué debe contener el prototipo; el Product Backlog lo descompone en historias; GitHub Projects lo distribuye entre sprints; los documentos técnicos describen cómo se construye; y las evidencias verificables demuestran lo que realmente se ha terminado.
