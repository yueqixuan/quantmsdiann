process PARSE_EMPIRICAL_LOG_TASK {
    label 'process_single'

    input:
    path log_file

    output:
    val parsed_result, emit: parsed_vals

    exec:
    def log_text = log_file.text
    def match = log_text.readLines().find { it.contains("Averaged recommended settings") }
    def mass_acc_ms2 = params.mass_acc_ms2
    def mass_acc_ms1 = params.mass_acc_ms1
    def scan_window  = params.scan_window
    if (match) {
        def parts = match.trim().split(/\s+/)
        // "Averaged recommended settings" line: field 11 = ms2, 15 = ms1, 19 = scan_window (1-indexed)
        def ms2 = parts.size() > 10 ? parts[10].replaceAll(/[^0-9.]/, '') : ''
        def ms1 = parts.size() > 14 ? parts[14].replaceAll(/[^0-9.]/, '') : ''
        def sw  = parts.size() > 18 ? parts[18].replaceAll(/[^0-9.]/, '') : ''
        if (ms2) mass_acc_ms2 = ms2
        if (ms1) mass_acc_ms1 = ms1
        if (sw)  scan_window  = sw
    }
    parsed_result = "${mass_acc_ms2},${mass_acc_ms1},${scan_window}"
}
