


NEURON  { 
  ARTIFICIAL_CELL ArtificialRhytmicCell
  RANGE freqs, latency, mu, kappa, I0, myseed, delta_t, spike_rate
}

UNITS {
  PI = (pi) (1) 
}


PARAMETER {
    freqs = 5 (Hz)    : frequency of oscillator in Hz
    latency = 10 (ms) : latency of spike generation
    spike_rate = 5    : spike rate in spikes per second
    
    kappa = 0.4       : kappa of von Mises distribution
    I0 = 1.04         : zero order Bessel function 
    mu = 0            : mean phase of von Mises distribution
    
    
    delta_t = 1 (ms)
    myseed = 0
    
   
}

ASSIGNED {
    randflag
    time_after_spike (ms)
    dt (ms)
    phase
    TWOPIIODFIRATIO
    TWOPI
    pdf
    delta_phase
    freqs_ratio
    
    
}


INITIAL {
    set_seed(myseed)
    phase = 0 
    
    delta_phase = freqs * 2 * PI * 0.001 * delta_t    : rad
    freqs_ratio = spike_rate / freqs                  : spikes per cycle of oscillation

    TWOPIIODFIRATIO = delta_phase * freqs_ratio / (2 * PI * I0)
    TWOPI = 2 * PI
    time_after_spike = latency + 1
    
    get_pdf_by_phase()
    net_send(1, 2)
    
}

NET_RECEIVE (w) { //запуск при инициализации
   
    get_pdf_by_phase()
         
    phase = phase + delta_phase
    if (phase > PI) {
        phase = phase - TWOPI
    }

    randflag = scop_random() : generate randomflag between 0 and 1
        
    if (randflag < pdf  && time_after_spike > latency) {
        : generate spike
        time_after_spike = 0
        net_send(delta_t, 1)
        net_event(t)
       
    } else { //Самовозбуждение
        time_after_spike = time_after_spike + delta_t
        net_send(delta_t, 1)
    }
    

}


PROCEDURE get_pdf_by_phase() {
    
    : TABLE pdf DEPEND phase FROM -4 TO 4 WITH 100
    
    pdf = exp(kappa * cos(phase - mu) ) * TWOPIIODFIRATIO
    

}

