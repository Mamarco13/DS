class ComparadorEspectrograma
  UMBRAL = 0.6

  def self.similitud(espectrograma_input, espectrograma_guardado, estrategia = 'coseno')
    if espectrograma_input.is_a?(String)
      begin
        espectrograma_input = JSON.parse(espectrograma_input)
      rescue JSON::ParserError
      end
    end

    if espectrograma_guardado.is_a?(String)
      begin
        espectrograma_guardado = JSON.parse(espectrograma_guardado)
      rescue JSON::ParserError
      end
    end

    if estrategia == 'mcff'
      similitud_estrategia_mfcc(espectrograma_input, espectrograma_guardado)
    else
      similitud_estrategia_coseno(espectrograma_input, espectrograma_guardado)
    end
  end

  def self.similitud_estrategia_coseno(input, guardado)
    perfil1 = input["perfil"] || perfil_espectral(input["frames"] || [])
    perfil2 = guardado["perfil"] || perfil_espectral(guardado["frames"] || [])

    return 0.0 if perfil1.nil? || perfil2.nil? || perfil1.empty? || perfil2.empty?

    perfil1 = Array(perfil1).map(&:to_f)
    perfil2 = Array(perfil2).map(&:to_f)

    similitud_coseno(perfil1, perfil2)
  end

  def self.similitud_estrategia_mfcc(input, guardado)
    mfcc1 = input["mfcc"]
    mfcc2 = guardado["mfcc"]

    return 0.0 if mfcc1.nil? || mfcc2.nil? || mfcc1.empty? || mfcc2.empty?

    # Convert to array of arrays of floats, ignoring invalid rows
    mfcc1 = mfcc1.map { |row| Array(row).map(&:to_f) }
    mfcc2 = mfcc2.map { |row| Array(row).map(&:to_f) }

    min_coef = [mfcc1.length, mfcc2.length].min
    return 0.0 if min_coef.zero?

    n_frames1 = mfcc1[0]&.length || 0
    n_frames2 = mfcc2[0]&.length || 0
    min_frames = [n_frames1, n_frames2].min
    return 0.0 if min_frames.zero?

    suma = 0.0
    validos = 0

    min_frames.times do |f|
      vec1 = min_coef.times.map { |k| mfcc1[k][f] }
      vec2 = min_coef.times.map { |k| mfcc2[k][f] }

      s = similitud_coseno(vec1, vec2)
      unless s.nan?
        suma += s
        validos += 1
      end
    end

    validos > 0 ? (suma / validos) : 0.0
  end

  def self.perfil_espectral(frames)
    return [] if frames.empty?

    bins = frames.map(&:length).min
    return [] if bins <= 1

    perfil = Array.new(bins - 1, 0.0)
    validos = 0

    frames.each do |frame|
      energia = frame.sum { |v| v.abs } / frame.length.to_f
      next if energia < 0.00001

      max_valor = frame[1..].max
      next if max_valor.nil? || max_valor <= 0.0001

      (1...bins).each { |i| perfil[i - 1] += Math.log(1.0 + frame[i]) }
      validos += 1
    end

    return [] if validos.zero?

    perfil.map! { |v| v / validos }

    radio = 2
    Array.new(perfil.length) do |i|
      ventana = perfil[[0, i - radio].max..[perfil.length - 1, i + radio].min]
      ventana.sum / ventana.length
    end
  end

  def self.similitud_coseno(a, b)
    a = Array(a).map(&:to_f)
    b = Array(b).map(&:to_f)

    n = [a.length, b.length].min
    return 0.0 if n.zero?

    dot = norm_a = norm_b = 0.0
    n.times do |i|
      dot   += a[i] * b[i]
      norm_a += a[i]**2
      norm_b += b[i]**2
    end

    denom = Math.sqrt(norm_a) * Math.sqrt(norm_b)
    denom < 1e-10 ? 0.0 : dot / denom
  end
end
